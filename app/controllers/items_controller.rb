# frozen_string_literal: true

class ItemsController < ApplicationController
  before_action :set_item, only: %i[show edit update destroy]

  # GET /items
  # GET /items.json
  def index
    @time_range = (params[:time_range] || 24).to_i
    if current_user
      @profile = params[:profile_id] ? current_user.profiles.where(id: params[:profile_id]).first : current_user.profiles.first
      @feeds = params[:feed_ids] ? Feed.where(id: params[:feed_ids]) : @profile.feeds.order(:title)
    else
      @feeds = params[:feed_ids] ? Feed.where(id: params[:feed_ids]) : Feed.all.order(:title)
    end
    @items = Item.includes(:feed).where(feed: @feeds).where('published_at > ?', Time.now - @time_range.hours).order(published_at: :desc)
  end

  # GET /items/1
  # GET /items/1.json
  def show; end

  # GET /items/new
  def new
    @item = Item.new
  end

  # GET /items/1/edit
  def edit; end

  # POST /items
  # POST /items.json
  def create
    @item = Item.new(item_params)

    respond_to do |format|
      if @item.save
        format.html { redirect_to @item, notice: 'Item was successfully created.' }
        format.json { render :show, status: :created, location: @item }
      else
        format.html { render :new }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /items/1
  # PATCH/PUT /items/1.json
  def update
    respond_to do |format|
      if @item.update(item_params)
        format.html { redirect_to @item, notice: 'Item was successfully updated.' }
        format.json { render :show, status: :ok, location: @item }
      else
        format.html { render :edit }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /items/1
  # DELETE /items/1.json
  def destroy
    @item.destroy
    respond_to do |format|
      format.html { redirect_to items_url, notice: 'Item was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_item
    @item = Item.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def item_params
    params.require(:item).permit(:title, :body, :url, :feed_id, :published_at)
  end
end
