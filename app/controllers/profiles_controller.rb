# frozen_string_literal: true

class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_profile, only: %i[show edit update destroy]

  def default
    redirect_to current_user.profiles.order(default: :desc).order(:name).first
  end

  # GET /profiles
  # GET /profiles.json
  def index
    @profiles = current_user.profiles.order(:name)
  end

  # GET /profiles/1
  # GET /profiles/1.json
  def show
    @show_images = @profile.show_images
    @menu_text = @profile
    @last_hours = (params[:last_hours] || @profile.last_hours).to_i
    @items = Item.includes(:feed, :item_users).where(feed_id: @profile.feed_ids).where('published_at > ?', (Time.now - @last_hours.hours)).order(published_at: :desc)
    @seen_items = current_user.item_users.where(item: @items).pluck(:item_id)
    @items = @items.to_a.keep_if { |item| !@seen_items.include? item.id } unless @profile.show_read_items
  end

  # GET /profiles/new
  def new
    @profile = Profile.new
  end

  # GET /profiles/1/edit
  def edit; end

  # POST /profiles
  # POST /profiles.json
  def create
    @profile = Profile.new(profile_params)
    @profile.user = current_user
    # @profile.feed_ids = Feed.pluck(:id)

    respond_to do |format|
      if @profile.save
        format.html { redirect_to @profile }
        format.json { render :show, status: :created, location: @profile }
      else
        format.html { render :new }
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /profiles/1
  # PATCH/PUT /profiles/1.json
  def update
    respond_to do |format|
      if @profile.update(profile_params)
        format.html { redirect_to @profile }
        format.json { render :show, status: :ok, location: @profile }
      else
        format.html { render :edit }
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /profiles/1
  # DELETE /profiles/1.json
  def destroy
    @profile.destroy
    respond_to do |format|
      format.html { redirect_to profiles_url }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_profile
    @profile = Profile.find(params[:id] || params[:profile_id])
  end

  # Only allow a list of trusted parameters through.
  def profile_params
    params.require(:profile).permit(:name, :default, :last_hours, :show_images, :show_read_items, feed_ids: [])
  end
end
