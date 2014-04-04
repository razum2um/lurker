class Api::V1::UsersController < ApplicationController
  def index
    @users = User.all
    render json: @users
  end

  def create
    @user = User.create(params[:user])
    render json: @user
  end

  def show
    @user = User.find(params[:id])
    render json: @user
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    render head: :ok
  end
end
