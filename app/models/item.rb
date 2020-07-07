# frozen_string_literal: true

class Item < ApplicationRecord
  include ActionView::Helpers::SanitizeHelper

  belongs_to :feed

  def summary(length = 300)
    sanitized = sanitize(body, tags: %w[p br ul li blockquote], attributes: %w[]).gsub('Continue reading', '').gsub('&hellip;', '').gsub('<blockquote>', '<p>').gsub('</blockquote>', '</p>').gsub('…', '')
    truncated = sanitized.slice(0, (sanitized.index(/[\.?!<]/, length) || -1))
    truncated || sanitized
  end

  def image
    original.to_h.extend Hashie::Extensions::DeepFind
    if (image_url = original.deep_find('image'))
      # Check if other items for this feed have the same image URL, indicates a recurring logo, not an useful image
      other_images = []
      feed.items.where.not(id: id).pluck(:original).collect do |other_original|
        other_original.extend Hashie::Extensions::DeepFind
        other_images << other_original.deep_find('image')
      end

      image_url = nil if other_images.uniq.compact.include?(image_url)
    end
    image_url
  end
end
