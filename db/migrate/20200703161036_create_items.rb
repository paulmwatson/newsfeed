# frozen_string_literal: true

class CreateItems < ActiveRecord::Migration[6.0]
  def change
    create_table :items, id: :uuid do |t|
      t.string :title, null: false
      t.text :body, null: false
      t.string :url, null: false
      t.references :feed, type: :uuid, null: false, foreign_key: true
      t.datetime :published_at, null: false

      t.timestamps
    end
  end
end
