class SettingsController < ApplicationController
  before_action :signed_in_user
  before_action :has_owner_access
  before_action :get_business
  before_action :get_subscriptions

  layout 'sidenav'

  def index
    @body_class = "with-sidebar show-sidebar"
    @user = @current_user
  end

  def billing
    @body_class = "with-sidebar show-sidebar"
    @user = @current_user
  end

  def plan
    @body_class = "with-sidebar show-sidebar"
    @user = @current_user
  end

  def profile
    @body_class = "with-sidebar show-sidebar"
    @user = @current_user
  end

  def support
    @body_class = "with-sidebar show-sidebar"
    @user = @current_user
  end

  def notifications
    @body_class = "with-sidebar show-sidebar"
    @user = @current_user
  end

end
