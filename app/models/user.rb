# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :profiles, dependent: :destroy
  has_many :feed_profiles, through: :profiles, dependent: :destroy
  has_many :feeds, through: :feed_profiles
  has_many :item_users, dependent: :destroy
  has_many :items, through: :item_users

  after_create :create_default_profile

  def create_default_profile
    profiles.create(name: 'World News', feed_ids: Feed.pluck(:id))
  end

  def to_s
    email
  end
end
