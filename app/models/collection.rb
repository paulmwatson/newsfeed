# frozen_string_literal: true

class Collection < ApplicationRecord
  has_many :collection_users, dependent: :destroy
  has_many :users, through: :collection_users
  has_many :collection_items, dependent: :destroy
  has_many :items, through: :collection_items

  enum collection_type: { read_later: 0 }

  def to_s
    name
  end
end
