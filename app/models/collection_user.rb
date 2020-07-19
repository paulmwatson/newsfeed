# frozen_string_literal: true

class CollectionUser < ApplicationRecord
  belongs_to :user
  belongs_to :collection

  enum role: { owner: 0 }
end
