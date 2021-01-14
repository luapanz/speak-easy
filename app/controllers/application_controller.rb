require './app/services/user_service'

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  include SessionsHelper
  protect_from_forgery with: :exception

  private

  def signed_in_user
    vars = request.query_parameters
    session[:return_to_user] = vars['username']
    session[:return_to] = request.url
    redirect_to login_url, notice: 'Please sign in.' unless signed_in?
  end

  def redirect_back_or_default(default)

    redirect_to_url = ((session[:return_to_user] == @current_user.username) && session[:return_to]) || default
    redirect_to(redirect_to_url)
    session[:return_to] = nil
    session[:return_to_user] = nil
  end

  def has_owner_access
    case @current_user.role
    when Role::AGENT
      redirect_to account_url, :flash => {:error => "Cannot access that page"}
    when Role::FRIEND
      redirect_to account_url, :flash => {:error => "Cannot access that page"}
    end
  end

  def can_access_business_settings
    case @current_user.role
    when Role::HR
      redirect_to home_dashboard_url, :flash => {:error => "Cannot access that page"}
    when Role::MANAGER
      redirect_to home_dashboard_url, :flash => {:error => "Cannot access that page"}
    end
  end

  def can_access_subscription_page
    case @current_user.role
    when Role::HR
      redirect_to home_dashboard_url, :flash => {:error => "Cannot access that page"}
    when Role::MANAGER
      redirect_to home_dashboard_url, :flash => {:error => "Cannot access that page"}
    when Role::MARKETING
      redirect_to home_dashboard_url, :flash => {:error => "Cannot access that page"}
    end
  end

  def get_business
    @business = Business.find(@current_user.business_id)
  end

  def get_subscriptions
    service = UserService.new
    date = Date.parse @current_user.createdAt
    lateDate = date + 7
    begin
      # Check if Free Trial 14 days
      if lateDate < Date.today
        service.has_active_subscriptions(@current_user.business_id)
      end
    rescue Exception => e
      redirect_to billing_index_path, :flash => {:error => e.message}
    end
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end
end
