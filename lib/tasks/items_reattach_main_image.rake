# frozen_string_literal: true

namespace :items do
  task reattach_main_image: :environment do
    puts 'Reattaching main_image of last 100 items'
    Item.order(published_at: :desc).limit(100).each(&:reattach_main_image)
  end
end
