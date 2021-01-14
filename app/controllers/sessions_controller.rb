class SessionsController < ApplicationController
  # before_action :authenticate_user!

  def new
    if session[:user_id]
      redirect_to home_dashboard_url
    end
  end

  def create
    user = User.authenticate(params[:username].downcase, params[:password])

    if user && user.emailVerified && user.is_active
      sign_in user

      if is_owner?
        redirect_back_or_default(home_dashboard_url)
        flash[:notice] = 'Logged in!'
      else
        redirect_to account_path, :notice => 'Logged in!'
      end
    else
      if user && !user.emailVerified
        flash.now.alert = '<span class="message">Please verify your email. Click <a href="javascript:void(0)" class="resend-email" data-username="' +params[:username].downcase+ '">here</a> to resend it</span>'
      else
        if user && !user.is_active
          flash[:error] = 'Your account has been deactivated by the business owner'
        else
          flash.now[:error] = 'Invalid username or password'
        end
      end
      render "new"
    end
  end

  def destroy
    session[:user_id] = nil

    redirect_to login_url, :notice => 'Logged out!'
  end
end
