# frozen_string_literal: true

class CreateFeeds < ActiveRecord::Migration[6.0]
  def change
    create_table :feeds, id: :uuid do |t|
      t.string :title, null: false
      t.string :description, null: false
      t.string :url, null: false

      t.timestamps
    end
  end
end
