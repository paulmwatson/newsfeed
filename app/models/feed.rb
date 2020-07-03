# frozen_string_literal: true

class Feed < ApplicationRecord
  require 'open-uri'
  has_many :items, dependent: :destroy

  validates :url, presence: true, uniqueness: true
  validates :title, presence: true
  validates :description, presence: true

  def to_s
    title
  end

  def self.import_from_opml(opml)
    feeds = []
    outline = OPML.load_file(opml)
    outline.extend Hashie::Extensions::DeepFind
    outline.deep_find_all('xmlUrl').each do |xml_url|
      feeds << import(xml_url)
    end
    feeds
  end

  def self.import(url)
    tries = 30

    begin
      puts("#{tries}: Importing #{url}")
      response = URI.open(url, redirect: false).read
    rescue OpenURI::HTTPRedirect => e
      url = e.uri.to_s # assigned from the "Location" response header
      retry if (tries -= 1) > 0
    rescue OpenURI::HTTPError, SocketError
      response = nil
    end

    if response
      begin
        feed = Feedjira.parse(response)
        if (new_feed = where(url: url).first_or_create(title: feed.title, description: 'Imported'))
          new_feed.fetch
          new_feed
        end
      rescue Feedjira::NoParserAvailable
        nil
      end
    end
  end

  def fetch
    new_items = []
    response = URI.open(url).read
    begin
      feed = Feedjira.parse(response)
      feed.entries.each do |entry|
        new_items << items.where(url: entry.url).first_or_create(title: entry.title, body: entry.summary || entry.content, published_at: entry.published)
      end
      new_items
    rescue Feedjira::NoParserAvailable
      nil
    end
  end
end
