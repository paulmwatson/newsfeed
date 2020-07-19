# frozen_string_literal: true

class CreateCollections < ActiveRecord::Migration[6.0]
  def change
    create_table :collections, id: :uuid do |t|
      t.string :name, null: false
      t.string :description, null: false
      t.integer :collection_type, null: false, default: 0
      t.boolean :public, null: false, default: false

      t.timestamps
    end

    create_table :collection_users, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.references :collection, type: :uuid, null: false, foreign_key: true
      t.integer :role, null: false, default: 0

      t.timestamps
    end

    create_table :collection_items, id: :uuid do |t|
      t.references :collection, type: :uuid, null: false, foreign_key: true
      t.references :item, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end

    add_column :users, :default_collection_id, :uuid
  end
end
