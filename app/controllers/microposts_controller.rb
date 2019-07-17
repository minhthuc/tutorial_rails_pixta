class MicropostsController < ApplicationController
  before_action :signed_in_user, only: %i[create destroy]
  before_action :correct_user, only: :destroy

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
    @micropost = current_user.microposts.build(micropost_params)
    flash[:success] = "Micropost created" if @micropost.save
    redirect_to root_path
  end

  # PATCH/PUT /microposts/1
  def update
    if @micropost.update(micropost_params)
      redirect_to @micropost, notice: "Micropost was successfully updated."
    else
      flash.now[:error] = "Can not edit this post!"
      render :edit
    end
  end

  # DELETE /microposts/1
  def destroy
    @micropost.destroy
    redirect_to root_path, notice: "Micropost was successfully destroyed."
  end

  private

  def correct_user
    @micropost = current_user.microposts.find_by(id: params[:id])
    if @micropost.nil?
      flash[:error] = "This post can not be found!"
      redirect_to root_path
    end
  end

  def micropost_params
    params.require(:micropost).permit(:content)
  end
end
