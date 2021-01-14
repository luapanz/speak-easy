class AgentSignupController < ApplicationController
  include Wicked::Wizard

  steps :start, :profile, :finish

  def show
    session[:team_member_params] ||= {}

    case step
      when :start
        @user = User.new
        @user.invite_code = params[:invite]
        @user.role = params[:role] ? params[:role] : Role::AGENT

        @role_name = Role::get_role_label(@user.role)

      when :profile
        jump_to :start unless session[:team_member_params].present?

        @user = User.new(session[:team_member_params])
        invite_code = session[:team_member_params]['invite_code']
        role = session[:team_member_params]['role']
        inv = Invitation.where(
            :code => invite_code,
            :role => role
        ).first

        @locations = []
        if inv.present?
          inv.location_ids.each do |loc|
            l = Location.find(loc)
            @locations.push l.name if l
          end
        end
      when :finish

    end

    render_wizard
  end

  def update
    session[:team_member_params] ||= {}

    case step
      when :start
        @user = User.new(user_params)
        invite_code = user_params[:invite_code]
        role = user_params[:role]
        @user.invite_code = invite_code
        inv = Invitation.where(
            :code => invite_code,
            :role => role
        ).first

        @role_name = Role::get_role_label(@user.role)

        if inv.present?
          formatted_phone = @user.phone

          if formatted_phone.to_i == inv.phone_number.to_s.last(4).to_i
            session[:team_member_params].deep_merge!(user_params) if user_params
            redirect_to next_wizard_path
          else
            flash.now[:error] = 'Last 4 digits of phone number don\'t match invite code.'
            render_wizard
          end

        else
          flash.now[:error] = 'Invite code not found.'
          render_wizard
        end

      when :profile
        @user = User.new(user_params)

        invite_code = session[:team_member_params]['invite_code']
        role = session[:team_member_params]['role']
        inv = Invitation.where(
            :code => invite_code,
            :role => role
        ).first
        business_id = inv.invitedBy.business_id if inv

        c = ParseResource::ParseConfig.config
        tos_version = c['params']['current_tos_version'] || 1

        @user.business_id = business_id
        @user.role = @user.role
        unless Role::is_valid_team_member_role(@user.role)
          @user.role = Role::get_default_team_member_role()
        end

        @user.is_active = true
        @user.locations = [{
                               :location_id => inv.location_ids[0],
                               :is_active => true
                           }]

        country_code = user_params[:country] || :us

        phone_number = inv.phone_number.to_s
        if phone_number.chars.first != '+'
          phone_number = "+" + phone_number
        end

        phone_number = GlobalPhone.parse(phone_number, country_code)

        if !phone_number.nil?
          @user.phone = phone_number.international_string
        else
          @user.phone = inv.phone_number.to_s
        end

        @user.tos_version = tos_version
        @user.tos_acceptance_date = DateTime.now
        @user.invite_code = nil
        @user.send_invitation = true
        @user.createdBy = inv.invitedBy.objectId
        @user.overall_rscore = 0

        @locations = []
        inv.location_ids.each do |loc|
          l = Location.find(loc)
          @locations.push l.name if l
        end

        if params[:user][:photo].present?
          path = params[:user][:photo].path
          folder = Cloudinary.config.folder

          i = Cloudinary::Uploader.upload(path, {:upload_preset => 'agentUpload', :folder => "#{folder}/Agents"}) rescue nil
          unless i.nil?
            if i['secure_url'].present?
              @user.photo_url = i['secure_url']
            end
          end
        end

        if @user.save
          if @user.objectId.present? && @user.photo_url.present?
            old_photo_name = File.basename(@user.photo_url, ".*")
            name_tag = @user.firstname + " " + @user.lastname

            Cloudinary::Uploader.add_tag([
                                             name_tag,
                                             'Business ID: ' + @user.business_id,
                                             'User ID: ' + @user.objectId], "#{folder}/Agents/#{old_photo_name}")
          end

          # inv.update_attributes(:is_accepted => true)
          inv.destroy
          session[:user_id] = @user.objectId if @user.objectId.present?
          session[:team_member_params] = nil
          redirect_to next_wizard_path, :notice => "You joined the #{@locations.join(', ')} team!"
        else
          flash.now[:error] = 'Unable to create new account.'
          render_wizard
        end
    end

  end

  private

  def user_params
    params.require(:user).permit(:phone, :country, :invite_code, :role, :firstname, :lastname, :password, :email, :username)
  end

end
