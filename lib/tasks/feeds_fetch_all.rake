# frozen_string_literal: true

namespace :feeds do
  task fetch_all: :environment do
    puts 'Fetching all feed items'
    Feed.all.each(&:fetch)
  end
end
