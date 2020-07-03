class FeedProfile < ApplicationRecord
  belongs_to :feed
  belongs_to :profile
end
