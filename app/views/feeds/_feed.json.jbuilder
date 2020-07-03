json.extract! feed, :id, :title, :description, :url, :created_at, :updated_at
json.url feed_url(feed, format: :json)
