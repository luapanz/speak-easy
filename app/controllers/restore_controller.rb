class RestoreController < ApplicationController
  # before_action :signed_in_user

  def index
    @user = User.new
  end

  def update
    @user = User.new(user_params)

    begin
      User.reset_password(user_params[:email].downcase)
      flash.now[:success] = 'Password recovery email sent. Please check your email to change your password.'
    rescue Exception => e
      parsed = JSON.parse(e.response.body)
      if parsed["code"] == 205
        flash.now[:error] = 'No account found with this email address.'
      else
        raise e
      end
    end

    render 'index'
  end

  private

  def user_params
    params.require(:user).permit(:email, :old_password, :new_password,
      :confirm_password)
  end
end
