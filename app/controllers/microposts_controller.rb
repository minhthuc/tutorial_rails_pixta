class MicropostsController < ApplicationController
  before_action :signed_in_user, only: %i[create destroy]
  before_action :set_micropost, only: %i[show edit update destroy]

  # GET /microposts
  def index
    @microposts = Micropost.all
  end

  # GET /microposts/1
  def show
  end

  # GET /microposts/new
  def new
    @micropost = Micropost.new
  end

  # GET /microposts/1/edit
  def edit
  end

  # POST /microposts
  def create
    @micropost = Micropost.new(micropost_params)

    if @micropost.save
      redirect_to @micropost, notice: 'Micropost was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /microposts/1
  def update
    if @micropost.update(micropost_params)
      redirect_to @micropost, notice: 'Micropost was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /microposts/1
  def destroy
    @micropost.destroy
    redirect_to microposts_url, notice: 'Micropost was successfully destroyed.'
  end

  private
  def set_micropost
    @micropost = Micropost.find(params[:id])
  end

  def micropost_params
    params.require(:micropost).permit(:content, :user_id)
  end
end
