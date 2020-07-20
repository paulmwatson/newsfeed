# frozen_string_literal: true

class ItemsController < ApplicationController
  before_action :authenticate_user!, only: %i[seen]
  before_action :set_item, only: %i[show edit update destroy seen]

  def read
    if item = Item.where(id: params[:item_id]).first
      current_user&.item_users&.create(item: item, user: current_user, action: :read)
      redirect_to item.url
    else
      redirect_to :root, notice: 'Cannot find that item'
    end
  end

  def seen
    current_user&.item_users&.create(item: @item, action: :seen)
    render json: true
  end

  # GET /items
  # GET /items.json
  def index
    @show_images = true
    @menu_text = I18n.t('navigation.personalise')
    @items = Item.includes(:feed).order(published_at: :desc).limit(100)
    @default_collection_items = current_user&.default_collection&.item_ids
    @seen_items = current_user&.item_users&.where(item: @items)&.pluck(:item_id)
  end

  # GET /items/1
  # GET /items/1.json
  def show
    @show_images = true
  end

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
    @item = Item.find(params[:id] || params[:item_id])
  end

  # Only allow a list of trusted parameters through.
  def item_params
    params.require(:item).permit(:title, :body, :url, :feed_id, :published_at)
  end
end
