# frozen_string_literal: true

class FeedsController < ApplicationController
  before_action :set_feed, only: %i[show edit update destroy]

  # GET /feeds/1
  # GET /feeds/1.json
  def show
    @items = @feed.items.order(published_at: :desc).limit(100)
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
