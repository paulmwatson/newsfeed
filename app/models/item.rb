# frozen_string_literal: true

class Item < ApplicationRecord
  include ActionView::Helpers::SanitizeHelper
  include ActionView::Helpers::TextHelper

  belongs_to :feed

  def summary(length = 300)
    truncate(strip_tags(body), length: length).gsub('Continue reading', '').gsub('&hellip;', '')
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
