# frozen_string_literal: true

class AddSettingsToProfile < ActiveRecord::Migration[6.0]
  def change
    add_column :profiles, :show_images, :boolean, null: false, default: true
    add_column :profiles, :show_read_items, :boolean, null: false, default: true
    add_column :profiles, :last_hours, :integer, null: false, default: 24
  end
end
