# frozen_string_literal: true

class ItemUser < ApplicationRecord
  belongs_to :item
  belongs_to :user
  enum action: { read: 0, seen: 1 }
end
