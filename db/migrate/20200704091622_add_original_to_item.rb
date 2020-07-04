# frozen_string_literal: true

class AddOriginalToItem < ActiveRecord::Migration[6.0]
  def change
    add_column :items, :original, :jsonb, null: false, default: {}
  end
end
