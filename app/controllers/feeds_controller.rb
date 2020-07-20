# frozen_string_literal: true

class FeedsController < ApplicationController
  before_action :set_feed, only: %i[show edit update destroy]

  def index
    @show_images = true
    @items = Feed.order(title: :asc).all.collect { |feed| feed.items.order(published_at: :desc).first }
  end

  # GET /feeds/1
  # GET /feeds/1.json
  def show
    @show_images = true
    @items = @feed.items.order(published_at: :desc).limit(100)
    @default_collection_items = current_user.default_collection.item_ids
    @seen_items = current_user.item_users.where(item: @items).pluck(:item_id) if current_user
  end

  def fetch
    render json: Feed.all.each(&:fetch)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_feed
    @feed = Feed.find(params[:id])
  end
end
