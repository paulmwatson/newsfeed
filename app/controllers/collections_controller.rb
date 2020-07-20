# frozen_string_literal: true

class CollectionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_collection, only: %i[show edit update destroy add_item remove_item]

  def add_item
    item = Item.find(params[:item_id])
    @collection.items << item unless @collection.item_ids.include? params[:item_id]

    if request.xhr?
      render json: true
    else
      redirect_to collection_url(@collection), notice: I18n.t('info.added_item_to_collection')
    end
  end

  def remove_item
    item = Item.find(params[:item_id])
    @collection.items.delete(item)

    if request.xhr?
      render json: true
    else
      redirect_to collection_url(@collection), notice: I18n.t('info.removed_item_from_collection')
    end
  end

  # GET /collections
  # GET /collections.json
  def index
    @show_images = false
    @hide_item_footer = true
    @item = Item.find(params[:item_id]) if params[:item_id]
    @collections = current_user.collections
  end

  # GET /collections/1
  # GET /collections/1.json
  def show
    @show_images = true
    @menu_text = @collection
    @items = @collection.items.order('collection_items.created_at': :desc)
    @default_collection_items = current_user.default_collection.item_ids
    @seen_items = current_user.item_users.where(item: @items, action: :read).pluck(:item_id) if @collection.read_later?
  end

  # GET /collections/new
  def new
    @collection = Collection.new
  end

  # GET /collections/1/edit
  def edit; end

  # POST /collections
  # POST /collections.json
  def create
    @collection = Collection.new(collection_params)

    respond_to do |format|
      if @collection.save
        format.html { redirect_to @collection, notice: 'Collection was successfully created.' }
        format.json { render :show, status: :created, location: @collection }
      else
        format.html { render :new }
        format.json { render json: @collection.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /collections/1
  # PATCH/PUT /collections/1.json
  def update
    respond_to do |format|
      if @collection.update(collection_params)
        format.html { redirect_to @collection, notice: 'Collection was successfully updated.' }
        format.json { render :show, status: :ok, location: @collection }
      else
        format.html { render :edit }
        format.json { render json: @collection.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /collections/1
  # DELETE /collections/1.json
  def destroy
    @collection.destroy
    respond_to do |format|
      format.html { redirect_to collections_url, notice: 'Collection was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_collection
    @collection = Collection.find(params[:id] || params[:collection_id])
  end

  # Only allow a list of trusted parameters through.
  def collection_params
    params.require(:collection).permit(:name, :description, :type)
  end
end
