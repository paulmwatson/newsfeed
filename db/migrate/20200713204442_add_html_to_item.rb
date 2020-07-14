# frozen_string_literal: true

class AddHtmlToItem < ActiveRecord::Migration[6.0]
  def change
    add_column :items, :html, :text, null: false, default: ''
  end
end
