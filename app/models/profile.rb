# frozen_string_literal: true

class Profile < ApplicationRecord
  belongs_to :user
  has_many :feed_profiles, dependent: :destroy
  has_many :feeds, through: :feed_profiles

  def to_s
    name
  end
end
