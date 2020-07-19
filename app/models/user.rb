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
  has_many :collection_users, dependent: :destroy
  has_many :collections, through: :collection_users
  belongs_to :default_collection, class_name: 'Collection', foreign_key: 'default_collection_id'

  before_validation :create_default_collection
  after_create :create_default_profile
  after_create :properly_associate_default_collection

  def create_default_profile
    profiles.create(name: 'World News', feed_ids: Feed.pluck(:id))
  end

  def create_default_collection
    if new_record?
      self.default_collection = Collection.create(name: 'Read Later', description: 'A list to read later.') # collection.id
    end
  end

  def properly_associate_default_collection
    collections << default_collection
  end

  def to_s
    email
  end
end
