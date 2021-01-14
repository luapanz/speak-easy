require './app/services/user_service'
require 'net/http'
require 'json'

class AjaxController < ApplicationController

  def show

  end

  def check_username
    u = User.where(:username => user_params[:username].downcase).first
    render :json => {valid: u.blank?}
  end

  def check_email
    u = User.where(:email => user_params[:email].downcase).first

    render :json => {valid: u.blank?}
  end

  def verify_email
    service = UserService.new
    begin
      service.resend_verification_email(@_request[:username])
      render :json => {}
    rescue Exception => e
      render :json => {:message => e.message}, status: 400
    end

  end

  def cancel_campaign
    begin
      @campaign = Campaign.find(@_request[:object_id])
      @campaign.run_date = DateTime.now
      if @campaign.save
        render :json => {}
      else
        render :json => {:message => e.message}, status: 400
      end
    rescue Exception => e
      render :json => {:message => e.message}, status: 400
    end
  end

  def send_sms
    begin
      uri = URI('https://sms.wsgo.net/api/messages')
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      req = Net::HTTP::Post.new(uri.path, {'Content-Type' => 'application/json'})
      req.body = {"api_token" => "o4tJ2h2NHRGFZlI9ZTOxvgCaMZUh7wypEFhW5GyHAxAmvIk1yBZVHGGz0mQ5", "from" => "18595255240", "to" => "1" + @_request[:number], "content": "https://speakeasy.page.link/getTheApp"}.to_json
      res = http.request(req)
      render :json => {}
    rescue => e
      puts "FAILED #{e}"
      render :json => {:message => e.message}, status: 400
    end
  end

  def send_team_sms
    service = UserService.new
    begin
      phoneNumber = @_request[:phoneNumber]
      businessId = @_request[:businessId]
      locationId = @_request[:locationId]
      service.send_team_member_link(phoneNumber, businessId, locationId)
      render :json => {}
    rescue Exception => e
      render :json => {:message => e.message}, status: 400
    end
  end

  def change_password
    begin
      oldPassword = @_request[:old_password]
      newPassword = @_request[:new_password]
      confirmPassord = @_request[:confirm_password]
      email = @_request[:email]
      service = UserService.new
      service.change_user_password(oldPassword, newPassword, email)
      render :json => {}
    rescue => e
      puts "FAILED #{e}"
      render :json => {:message => e.message}, status: 400
    end
  end

  def subscribe
    begin
      token = @_request[:token]
      planId = @_request[:planId]
      businessId = @_request[:businessId]

      service = UserService.new
      response = service.create_subscription(token, planId, businessId)
      if response == "success"
        respond_to do |format|
          flash[:success] = 'Successfully Subscribed'
          flash.keep(:success)
          format.js {render js: "window.location = '#{billing_index_path}'"}
        end
      else
        respond_to do |format|
          flash[:error] = "Error: " + response
          flash.keep(:error)
          format.js {render js: "window.location = '#{billing_index_path}'"}
        end
      end
    rescue => e
      puts "FAILED #{e}"
      render :json => {:message => e.message}, status: 400
    end
  end

  def update_card
    begin
      token = @_request[:token]
      businessId = @_request[:businessId]

      service = UserService.new
      response = service.update_card(businessId, token)
      if response == "success"
        respond_to do |format|
          flash[:success] = 'Card Updated'
          flash.keep(:success)
          format.js {render js: "window.location = '#{billing_index_path}'"}
        end
      else
        respond_to do |format|
          flash[:error] = "Error: " + response
          flash.keep(:error)
          format.js {render js: "window.location = '#{billing_index_path}'"}
        end
      end
    rescue => e
      puts "FAILED #{e}"
      render :json => {:message => e.message}, status: 400
    end
  end

  def update_subscription
    begin
      businessId = @_request[:businessId]
      planId = @_request[:planId]

      service = UserService.new
      response = service.update_subscription(businessId, planId)
      if response == "success"
        respond_to do |format|
          flash[:success] = 'Subscription Updated'
          flash.keep(:success)
          format.js {render js: "window.location = '#{billing_index_path}'"}
        end
      else
        respond_to do |format|
          flash[:error] = "Error: " + response
          flash.keep(:error)
          format.js {render js: "window.location = '#{billing_index_path}'"}
        end
      end
    rescue => e
      puts "FAILED #{e}"
      render :json => {:message => e.message}, status: 400
    end
  end

  def cancel_subscription
    begin
      businessId = @_request[:businessId]

      service = UserService.new
      response = service.cancel_subscription(businessId)
      if response == "success"
        respond_to do |format|
          flash[:success] = 'Subscription Cancelled'
          flash.keep(:success)
          format.js {render js: "window.location = '#{billing_index_path}'"}
        end
      else
        respond_to do |format|
          flash[:error] = "Error: " + response
          flash.keep(:error)
          format.js {render js: "window.location = '#{billing_index_path}'"}
        end
      end
    rescue => e
      puts "FAILED #{e}"
      render :json => {:message => e.message}, status: 400
    end
  end

  def activate_subscription
    begin
      businessId = @_request[:businessId]

      service = UserService.new
      response = service.activate_subscription(businessId)
      if response == "success"
        respond_to do |format|
          flash[:success] = 'Subscription Cancelled'
          flash.keep(:success)
          format.js {render js: "window.location = '#{billing_index_path}'"}
        end
      else
        respond_to do |format|
          flash[:error] = "Error: " + response
          flash.keep(:error)
          format.js {render js: "window.location = '#{billing_index_path}'"}
        end
      end
    rescue => e
      puts "FAILED #{e}"
      render :json => {:message => e.message}, status: 400
    end
  end

  def update_users_subscription
    begin
      businessId = @_request[:businessId]
      userAmount = @_request[:userAmount]

      service = UserService.new
      response = service.update_users_subscription(businessId, userAmount)
      if response == "success"
        respond_to do |format|
          flash[:success] = 'Subscription Updated'
          flash.keep(:success)
          format.js {render js: "window.location = '#{billing_index_path}'"}
        end
      else
        respond_to do |format|
          flash[:error] = "Error: " + response
          flash.keep(:error)
          format.js {render js: "window.location = '#{billing_index_path}'"}
        end
      end
    rescue => e
      puts "FAILED #{e}"
      render :json => {:message => e.message}, status: 400
    end
  end

  def disable_onboarding_dialog
    u = User.where(:email => @_request[:email]).first
    u.show_dialog = false
    u.save
    render :json => {}
  end

  private

  def user_params
    params.require(:user).permit(:username, :email)
  end
  
  

end
