# frozen_string_literal: true

class Item < ApplicationRecord
  include ActionView::Helpers::SanitizeHelper

  has_many :item_users, dependent: :destroy
  has_one_attached :main_image, acl: :public
  has_many :collection_items, dependent: :destroy
  has_many :collections, through: :collection_items

  belongs_to :feed

  after_commit :get_html_and_main_image

  def summary(length = 300)
    sanitized = sanitize(body, tags: %w[p br ul li blockquote], attributes: %w[]).gsub('Read more', '').gsub('Continue reading', '').gsub('&hellip;', '').gsub('<blockquote>', '<p>').gsub('</blockquote>', '</p>').gsub('…', '').gsub('<p></p>', '')
    truncated = sanitized.slice(0, (sanitized.index(/[\.?!<]/, length) || -1))
    truncated || sanitized
  end

  def open_graph_image_urls
    uris = []
    html.scan(/<meta[^>]+property="og:image"[^>]+content="([^">]+)"/).flatten.each do |url|
      uris << URI.parse(url)
    rescue URI::InvalidURIError
      next
    end
    uris.collect(&:to_s)
  end

  def image_urls
    urls = []
    uris = []

    original_extended = original.to_h.extend Hashie::Extensions::DeepFind
    urls << original_extended.deep_find('image')
    urls << original['content']&.scan(/<img[^>]+src="([^">]+)"/)
    urls << original['summary']&.scan(/<img[^>]+src="([^">]+)"/)
    urls << original['description']&.scan(/<img[^>]+src="([^">]+)"/)
    urls << original['content:encoded']&.scan(/<img[^>]+src="([^">]+)"/)
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

  def get_image_size_and_extensions(urls)
    urls_with_size_and_extension = []
    urls.each do |url|
      url_metadata = { url: url }
      url_metadata[:size] = Rails.cache.fetch("fastimage_size_#{Digest::MD5.hexdigest(url)}", skip_nil: true) do
        FastImage.size(url, http_header: { 'User-Agent': 'Wget/1.11.4' })
      end
      url_metadata[:extension] = Rails.cache.fetch("fastimage_type_#{Digest::MD5.hexdigest(url)}", skip_nil: true) do
        FastImage.type(url, http_header: { 'User-Agent': 'Wget/1.11.4' })
      end
      urls_with_size_and_extension << url_metadata
    end
    urls_with_size_and_extension
  end

  def largest_valid_image
    get_image_size_and_extensions(image_urls).keep_if { |url| %i[jpg png jpeg gif].include? url[:extension] }.max_by { |url| url[:size] ? url[:size][0] : 0 }
  end

  def best_image
    get_image_size_and_extensions(open_graph_image_urls)[0] || largest_valid_image
  end

  def attach_main_image
    reattach_main_image unless main_image.attached?
  end

  def reattach_main_image
    if best_image
      main_image.detach
      url_to_use = best_image[:url]
      require 'open-uri'
      image = StringIO.new(Rails.cache.fetch("image_#{Digest::MD5.hexdigest(url_to_use)}", skip_nil: true) do
        URI.open(url_to_use).read
      end)
      file_name = "#{id}_main_image.#{best_image[:extension]}"
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
    url_html = Rails.cache.fetch("html_#{Digest::MD5.hexdigest(url)}", skip_nil: true) do
      URI.open(url).read
    end
    update(html: url_html)
  rescue OpenURI::HTTPError
    false
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
