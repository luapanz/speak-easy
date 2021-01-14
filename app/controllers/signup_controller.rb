class SignupController < ApplicationController
  layout '_base'

  def index
    c = ParseResource::ParseConfig.config
    tos_version = c['params']['current_tos_version'] || 1
    @user = User.new
    @user.tos_version = tos_version
  end

  def update
    puts "Adding User!"
    response.headers.delete('X-Frame-Options')
      # @user.business_name is attr_accessor, so we don't want to save it
      # else if we leave it as is, new column will be created in Users table
      # we save it to temporary variable to show it on form if something went wrong with save
    c = ParseResource::ParseConfig.config
    business_name = params[:user][:business_name]

    user_params.delete(:password_confirmation)
    coupon = user_params[:coupon]
    user_params.delete :coupon

    if coupon.present?
      free = c['params']['coupon_free']
      sixty = c['params']['coupon_60']
      enterprise = c['params']['coupon_enterprise']
      if coupon == free || coupon == sixty || coupon == enterprise
        code = ''
        if coupon == free
          code = 'coupon_free'
        elsif coupon == sixty
          code = 'coupon_sixty'
        elsif coupon == enterprise
          code = 'coupon_enterprise'
        end

        @user = User.new()

        business_id = nil
        c = ParseResource::ParseConfig.config
        tos_version = c['params']['current_tos_version'] || 1
        business = Business.new({
                                    :name => business_name,
                                    :sms_text => c['params']['default_sms_message'],
                                    :billing_email => @user.email || '',
                                    :business_phone => @user.phone || '',
                                    :coupon => code
                                })


        if business.save
          business_id = business.objectId
        end

        @user.firstname = user_params[:firstname]
        @user.lastname = user_params[:lastname]
        @user.email = user_params[:email]
        @user.password = user_params[:password]
        @user.phone = user_params[:phone]
        @user.business_id = business_id
        @user.is_active = true
        @user.tos_version = tos_version
        @user.tos_acceptance_date = DateTime.now
        @user.send_invitation = true
        @user.email.downcase!
        @user.role = Role::OWNER
        @user.username = @user.email
        @user.send_notifications = true
        @user.show_dialog = true
        puts "Sign up"

        if @user.save
          session[:tmp_user_id] = @user.objectId if @user.objectId.present?
          session[:tmp_business_id] = business_id
          user = User.authenticate(@user.email, user_params[:password])
          if user && user.emailVerified && user.is_active
            sign_in user

            if is_owner?
              redirect_back_or_default(home_dashboard_url)
            else
              redirect_to account_path, :notice => 'Logged in!'
            end
          else
            redirect_to login_url
          end
        else
          @user.business_name = business_name
          redirect_to :back, error: 'Unable to create new account.'
          return
        end
      else
        redirect_to :back, error: 'Invalid Coupon Code'
      end
    else
      puts "No Coupon"
      @user = User.new()

      business_id = nil
      c = ParseResource::ParseConfig.config
      tos_version = c['params']['current_tos_version'] || 1
      business = Business.new({
                                  :name => business_name,
                                  :sms_text => c['params']['default_sms_message'],
                                  :billing_email => @user.email || '',
                                  :business_phone => @user.phone || ''
                              })


      if business.save
        business_id = business.objectId
      end

      @user.firstname = user_params[:firstname]
      @user.lastname = user_params[:lastname]
      @user.email = user_params[:email]
      @user.password = user_params[:password]
      @user.phone = user_params[:phone]
      @user.business_id = business_id
      @user.is_active = true
      @user.tos_version = tos_version
      @user.tos_acceptance_date = DateTime.now
      @user.send_invitation = true
      @user.email.downcase!
      @user.role = Role::OWNER
      @user.username = @user.email
      @user.send_notifications = true
      @user.show_dialog = true
      puts "Sign up"

      if @user.save
        session[:tmp_user_id] = @user.objectId if @user.objectId.present?
        session[:tmp_business_id] = business_id
        user = User.authenticate(@user.email, user_params[:password])
        if user && user.emailVerified && user.is_active
          sign_in user

          if is_owner?
            redirect_back_or_default(home_dashboard_url)
          else
            redirect_to account_path, :notice => 'Logged in!'
          end
        else
          redirect_to login_url
        end
      else
        @user.business_name = business_name
        redirect_to :back, error: 'Unable to create new account.'
        return
      end
    end
  end


  private

  def user_params
    params.require(:user).permit(:phone, :country, :firstname, :lastname, :password, :password_confirmation, :email, :coupon, :username,
                                 :locations => [:name, :country, :street, :city, :suite, :state, :zip, :phone,
                                                :url, :is_virtual, :logo])
  end
end
