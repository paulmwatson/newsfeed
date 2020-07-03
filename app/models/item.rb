# frozen_string_literal: true

class Item < ApplicationRecord
  include ActionView::Helpers::SanitizeHelper
  include ActionView::Helpers::TextHelper

  belongs_to :feed

  def summary(length = 300)
    truncate(strip_tags(body), length: length).gsub('Continue reading', '').gsub('&hellip;', '')
  end
end
