# frozen_string_literal: true

class Item < ApplicationRecord
  include ActionView::Helpers::SanitizeHelper

  has_many :item_users, dependent: :destroy
  has_one_attached :main_image, acl: :public

  belongs_to :feed

  after_commit :get_html_and_main_image

  def summary(length = 300)
    sanitized = sanitize(body, tags: %w[p br ul li blockquote], attributes: %w[]).gsub('Read more', '').gsub('Continue reading', '').gsub('&hellip;', '').gsub('<blockquote>', '<p>').gsub('</blockquote>', '</p>').gsub('…', '').gsub('<p></p>', '')
    truncated = sanitized.slice(0, (sanitized.index(/[\.?!<]/, length) || -1))
    truncated || sanitized
  end

  def image_urls
    urls = []
    uris = []
    original_extended = original.to_h.extend Hashie::Extensions::DeepFind
    urls << original_extended.deep_find('image')
    urls << (original['content'] || original['summary']).scan(/<img[^>]+src="([^">]+)"/)
    urls << html.scan(/<img[^>]+src="([^">]+)"/)
    urls << html.scan(/<meta[^>]+property="og:image"[^>]+content="([^">]+)"/)
    urls.flatten.uniq.compact.each do |url|
      uri = URI.parse(url)
      next if uri.scheme == 'data'

      uri.host = feed.url_host unless uri.host
      uri.scheme = feed.url_scheme unless uri.scheme
      uris << uri
    rescue URI::InvalidURIError
      next
    end
    uris.collect(&:to_s)
  end

  def image_url_sizes_and_extension
    urls = []
    unless image_urls.empty?
      image_urls.each do |url|
        url_metadata = { url: url }
        url_metadata[:size] = Rails.cache.fetch("image_size_#{Digest::MD5.hexdigest(url)}") do
          FastImage.size(url)
        end
        url_metadata[:extension] = Rails.cache.fetch("image_type_#{Digest::MD5.hexdigest(url)}") do
          FastImage.type(url)
        end
        urls << url_metadata
      end
    end
    urls
  end

  def largest_main_image
    image_url_sizes_and_extension.keep_if { |url| %i[jpg png jpeg gif].include? url[:extension] }.max_by { |url| url[:size] ? url[:size][0] : 0 }
  rescue StandardError
    nil
  end

  def seen_by?(user)
    item_users.where(user: user).count > 0
  end

  def attach_main_image
    reattach_main_image unless main_image.attached?
  end

  def reattach_main_image
    main_image.detach
    if largest_main_image && largest_main_image[:size][0] > 100 && largest_main_image[:size][1] > 50
      url_to_use = largest_main_image[:url]
      require 'open-uri'
      image = StringIO.new(Rails.cache.fetch("image_#{Digest::MD5.hexdigest(url_to_use)}") do
        URI.open(url_to_use).read
      end)
      file_name = "#{id}_main_image.#{largest_main_image[:extension]}"
      main_image.attach(io: image, filename: file_name)
      main_image.variant(resize: '400x').processed # Note: Eager loads the variant file to S3 so we can use .service_url later
      main_image.variant(resize: '150x').processed
    end
  end

  def main_image_width
    main_image.metadata[:width] || 0
  rescue StandardError
    0
  end

  def set_html
    url_html = Rails.cache.fetch("html_#{Digest::MD5.hexdigest(url)}") do
      URI.open(url).read
    end
    update(html: url_html)
  end

  def get_html_and_main_image
    set_html if html.empty?
    attach_main_image unless main_image.attached?
  end

  def reget_html_and_main_image
    set_html
    reattach_main_image
  end
end
