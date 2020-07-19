# frozen_string_literal: true

class PopulateExistingUserDefaultCollection < ActiveRecord::Migration[6.0]
  def up
    User.all.each do |user|
      user.collections.create(name: 'Read Later', description: 'A list to read later.')
      user.update(default_collection: user.collections.first)
      user.default_collection.items << Item.order('RANDOM()').limit(2)
    end

    change_column :users, :default_collection_id, :uuid, null: false
  end

  def down; end
end
