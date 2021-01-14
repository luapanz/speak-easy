class ExtraController < ApplicationController
  include Wicked::Wizard

  steps :index, :locations, :finish

  before_action :signed_in_user
  before_action :get_business
  before_action :get_subscriptions

  def show
    case step
    when :index
      vars = request.query_parameters
      username = vars['username']
      @user = @current_user
      if username != @user.username
        redirect_to logout_url
        return
      end
    when :locations
      @can_create_more_locations = can_create_more_locations?
      @locations = []
      @locations << Location.new
    when :finish
      redirect_to new_agent_path
      return
    end
    render_wizard
  end

  def update
    case step
    when :index

      @user = @current_user
      up = user_params

      business_name = params[:user][:business_name]
      @business = Business.find(@current_user.business_id)
      @business.name = business_name
      @business_phone = @user.phone
      @business.save

      up.delete(:email)

      if params[:user][:photo].present?
        path = params[:user][:photo].path
        folder = Cloudinary.config.folder

        if @user.photo_url.present?
          old_photo_url = File.basename(@user.photo_url, ".*")
          d = Cloudinary::Api.delete_resources(["#{folder}/Agents/#{old_photo_url}"])
          @user.photo_url = "" if d["deleted"]["#{folder}/Agents/#{old_photo_url}"] == "deleted"
        end

        i = Cloudinary::Uploader.upload(path, {:upload_preset => 'agentUpload', :folder => "#{folder}/Agents"})

        if i['secure_url'].present?
          @user.photo_url = i['secure_url']
        end

        name_tag = @user.firstname + " " + @user.lastname
        new_photo_url = File.basename(@user.photo_url, ".*")

        Cloudinary::Uploader.add_tag([
                                         name_tag,
                                         'Business ID: ' + @user.business_id,
                                         'User ID: ' + @user.objectId], "#{folder}/Agents/#{new_photo_url}")
      end

      if @user.update_attributes(up)
        flash.now[:success] = 'Successfully updated.'
        redirect_to next_wizard_path
      else
        flash.now[:error] = 'Failed to update Team Member.'
        render_wizard
      end

    when :locations
      @locations = []
      @user = @current_user

      user_params[:locations].each do |ul|
        location_image = nil

        if ul[:logo].present?
          path = ul[:logo].path
          folder = Cloudinary.config.folder

          i = Cloudinary::Uploader.upload(path, {:upload_preset => 'logoUpload', :folder => "#{folder}/Locations"}) rescue nil

          unless i.nil?
            if i['secure_url'].present?
              location_image = i['secure_url']
            end
          end

          ul.delete :logo
        end

        lp = ul
        lp[:is_active] = true
        lp[:is_virtual] = ActiveRecord::Type::Boolean.new.type_cast_from_user(ul[:is_virtual])

        location = Location.new(lp)
        location.logo_url = location_image
        location.createdBy = @user.objectId
        location.business_id = @user.business_id

        @locations << location
      end

      if Location.save_all(@locations)
        @locations.each do |l|
          if l.logo_url.present? && l.objectId.present?
            old_logo_name = File.basename(l.logo_url, ".*")
            Cloudinary::Uploader.add_tag([
                                             'Business ID: ' + l.business_id,
                                             'Location ID: ' + l.objectId], "#{folder}/Locations/#{old_logo_name}")
          end
        end

        redirect_to next_wizard_path
      else
        flash.now[:error] = 'Unable to create new locations.'
        render_wizard
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
