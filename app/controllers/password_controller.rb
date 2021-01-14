class PasswordController < ApplicationController
  before_action :signed_in_user

  layout 'sidenav'
  def index
    @body_class = "with-sidebar show-sidebar"
    @user = @current_user
  end

  def update
    @user = @current_user

    password_params = user_params

    if password_params[:password] != password_params[:password_confirmation]
      flash[:error] = 'Password does not match the confirm password.'
    else
      if !User.check_password(@user.username, password_params[:old_password])
        flash[:error] = 'Your current password is incorrect.'
      else
        if @user.present?
          @user.password = password_params[:password]

          if @user.save
            flash[:success] = 'Password was changed.'
          else
            flash[:error] = 'You can\'t change the password.'
          end
        else

        end

      end

    end

    render 'index'
  end

  private

  def user_params
    params.require(:user).permit(:old_password, :password, :password_confirmation)
  end
end
