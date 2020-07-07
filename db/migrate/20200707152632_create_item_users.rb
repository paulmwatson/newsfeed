# frozen_string_literal: true

class CreateItemUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :item_users, id: :uuid do |t|
      t.references :item, type: :uuid, null: false, foreign_key: true
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.integer :action, null: false, default: 0

      t.timestamps
    end
  end
end
