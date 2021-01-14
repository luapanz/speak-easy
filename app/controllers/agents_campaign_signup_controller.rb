class AgentsCampaignSignupController < ApplicationController
  include Wicked::Wizard

  steps :welcome, :signup, :finish

  def show
    session[:business_id] = nil

    case step
      when :welcome
        parameters = params[:info]
        if parameters.present? && parameters.mb_chars.length == 20
          @businessId = parameters[0,10]
          session[:buisness_id] = parameters[0,10]
          @location = parameters[10,20]
          @info = parameters[0,20]
        # elsif parameters.present? && parameters.mb_chars.length == 22
        #   puts "Show this one!"
        #   @show_access = true
        #   @business = Business.find(parameters[2,10])
        #   @business.object_id = parameters[2,10]
        #   session[:buisness_id] = parameters[2,10]
        #   @location = parameters[12,22]
        #   @info = parameters[0,22]
        end

      when :signup
        # c = ParseResource::ParseConfig.config
        # tos_version = c['params']['current_tos_version'] || 1
        # @user = User.new
        # @user.tos_version = tos_version
        # parameters = params[:info]
        # if parameters.present? && parameters.mb_chars.length == 20
        #   @business = Business.find(parameters[0,10])
        #   @business.object_id = parameters[0,10]
        #   session[:buisness_id] = parameters[0,10]
        #   @location = parameters[10,20]
        #   @info = parameters[0,20]
        # else parameters.present? && parameters.mb_chars.length == 22
        #   @show_access = true
        #   @business = Business.find(parameters[2,12])
        #   @business.object_id = parameters[2,12]
        #   session[:buisness_id] = parameters[2,12]
        #   @location = parameters[12,22]
        #   @info = parameters[0,22]
        # end
      when :finish

    end
    render_wizard
  end

  def update
    case step
      when :welcome
        redirect_to next_wizard_path
      when :signup
        # response.headers.delete('X-Frame-Options')
        # business_id = params[:business_param]
        # location_id = params[:location_param]
        #
        # c = ParseResource::ParseConfig.config
        # tos_version = c['params']['current_tos_version'] || 1
        #
        # @user = User.new(user_params)
        # @user.business_id = business_id
        # @user.is_active = true
        # @user.tos_version = tos_version
        # @user.tos_acceptance_date = DateTime.now
        # @user.send_invitation = true
        # @user.email.downcase!
        # @user.role = Role::AGENT
        # @user.username = @user.email
        # @user.send_notifications = true
        # @user.locations = [
        #     {
        #         :location_id => location_id,
        #         :is_active => true
        #     }
        # ]
        #
        # # FOR BETA!!!!!!!!!!!!!!!!!
        # @user.beta_tester = true
        #
        # puts @user.business_id
        # puts @user.email

        if @user.save
          redirect_to next_wizard_path
        else
          redirect_to :back, notice: 'Sorry. Something went wrong.'
        end
    end
  end

  private

  def user_params
    params.require(:user).permit(:phone, :country, :firstname, :lastname, :password, :email, :username,
                                 :locations => [:name, :country, :street, :city, :suite, :state, :zip, :phone,
                                                :url, :is_virtual, :logo])
  end

end
