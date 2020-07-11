# frozen_string_literal: true

namespace :feeds do
  task fetch_all: :environment do
    say 'Fetching all feed items'
    Feed.all.each(&:fetch)
  end
end
