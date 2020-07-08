# frozen_string_literal: true

class AddDefaultToProfile < ActiveRecord::Migration[6.0]
  def change
    add_column :profiles, :default, :boolean, null: false, default: false
  end
end
