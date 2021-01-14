class AccountController < ApplicationController
  before_action :signed_in_user
  before_action :get_business

  layout 'sidenav'

  def index
    @user = @current_user
    @body_class = "with-sidebar show-sidebar"
  end

  def update
    @user = @current_user
    up = user_params

    # up[:username].downcase!
    up[:email].downcase!

    # do not send email to update_attributes if it did not changed
    if up[:email] == @user.email
      up.delete(:email)
    end

    if params[:account_cropped_photo].present?
      path = params[:account_cropped_photo]
      folder = Cloudinary.config.folder

      if @user.photo_url.present?
        old_photo_url       = File.basename(@user.photo_url, ".*")
        d                   = Cloudinary::Api.delete_resources( ["#{folder}/Agents/#{old_photo_url}"] )
        @user.photo_url     = "" if d["deleted"]["#{folder}/Agents/#{old_photo_url}"] == "deleted"
      end

      i = Cloudinary::Uploader.upload(path, {:upload_preset => 'agentUpload', :folder => "#{folder}/Agents"})

      if i['secure_url'].present?
        @user.photo_url = i['secure_url']
      end

      name_tag      = @user.firstname + " " + @user.lastname
      new_photo_url = File.basename(@user.photo_url, ".*")

      Cloudinary::Uploader.add_tag([
        name_tag,
        'Business ID: ' + @user.business_id,
        'User ID: ' + @user.objectId], "#{folder}/Agents/#{new_photo_url}")
    end

    if @user.update_attributes(up)
      flash.now[:success] = 'Successfully updated.'
      redirect_to :account
    else
      flash.now[:error] = 'Failed to update Team Member.'
      redirect_to :account
    end

  end

  private

  def user_params
    params.require(:user).permit(:firstname, :lastname, :phone, :email)
  end
end
