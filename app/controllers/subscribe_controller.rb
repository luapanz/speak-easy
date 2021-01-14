class SubscribeController < ApplicationController
  # before_action :signed_in_user

  def index
  end

  def update
    render 'index'
  end

  private

  def user_params
  end
end
