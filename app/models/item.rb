# frozen_string_literal: true

class Item < ApplicationRecord
  include ActionView::Helpers::SanitizeHelper

  has_many :item_users, dependent: :destroy
  has_one_attached :main_image

  belongs_to :feed

  after_create :attach_main_image

  def summary(length = 300)
    sanitized = sanitize(body, tags: %w[p br ul li blockquote], attributes: %w[]).gsub('Read more', '').gsub('Continue reading', '').gsub('&hellip;', '').gsub('<blockquote>', '<p>').gsub('</blockquote>', '</p>').gsub('…', '').gsub('<p></p>', '')
    truncated = sanitized.slice(0, (sanitized.index(/[\.?!<]/, length) || -1))
    truncated || sanitized
  end

  def image_urls
    urls = []
    original_extended = original.to_h.extend Hashie::Extensions::DeepFind
    urls << original_extended.deep_find('image')
    urls << (original['content'] || original['summary']).scan(/<img[^>]+src="([^">]+)"/)
    urls.flatten.uniq.compact
  end

  def image_url_sizes
    sizes = {}
    unless image_urls.empty?
      image_urls.each do |url|
        sizes[url] = Rails.cache.fetch("image_size_#{Digest::MD5.hexdigest(url)}") do
          FastImage.size(url)
        end
      end
    end
    sizes
  end

  def largest_main_image
    image_url_sizes.max_by { |url| url[0] }.flatten
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
    main_image.detach if main_image.attached?
    if largest_main_image && largest_main_image[1] > 100 && largest_main_image[2] > 50
      url_to_use = largest_main_image[0]
      require 'open-uri'
      image = StringIO.new(Rails.cache.fetch("image_#{Digest::MD5.hexdigest(url_to_use)}") do
        URI.open(url_to_use).read
      end)
      image_extension = FastImage.type(image).to_s
      file_name = "#{id}_main_image.#{image_extension}"
      main_image.attach(io: image, filename: file_name)
    end
  end

  def main_image_width
    main_image.metadata[:width]
  end
end
