# frozen_string_literal: true

class Profile < ApplicationRecord
  belongs_to :user
  has_many :feed_profiles, dependent: :destroy
  has_many :feeds, through: :feed_profiles
  has_many :items, through: :feeds

  validates :name, presence: true
  validates_uniqueness_of :name, scope: :user

  def to_s
    name
  end

  def self.last_hours
    [24, 72, 8760]
  end
end
