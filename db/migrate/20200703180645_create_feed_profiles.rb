# frozen_string_literal: true

class CreateFeedProfiles < ActiveRecord::Migration[6.0]
  def change
    create_table :feed_profiles, id: :uuid do |t|
      t.references :feed, type: :uuid, null: false, foreign_key: true
      t.references :profile, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end
  end
end
