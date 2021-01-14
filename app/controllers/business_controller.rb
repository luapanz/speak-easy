class BusinessController < ApplicationController
  before_action :signed_in_user
  before_action :has_owner_access
  before_action :get_business
  before_action :get_subscriptions
  before_action :can_access_business_settings

  layout 'sidenav'

  def index
    @body_class = "with-sidebar show-sidebar"
    @user = @current_user
    @business_types = BusinessType.all
  end

  def update
    @business_types = BusinessType.all
    bp              = business_params

    bp[:billing_email].downcase!

    if params[:new_logo_photo].present?
      path = params[:new_logo_photo]
      folder = Cloudinary.config.folder

      if @business.logo_url.present?
        old_logo_url        = File.basename(@business.logo_url, ".*")
        d                   = Cloudinary::Api.delete_resources( ["#{folder}/Businesses/#{old_logo_url}"] )
        @business.logo_url  = "" if d["deleted"]["#{folder}/Businesses/#{old_logo_url}"] == "deleted"
      end

      i = Cloudinary::Uploader.upload(path, {
          :upload_preset => 'logoUpload',
          :folder => "#{folder}/Businesses"
        })

      if i['secure_url'].present?
        @business.logo_url = i['secure_url']
      end

      new_logo_name = File.basename(@business.logo_url, ".*")
      Cloudinary::Uploader.add_tag(
        ['Business ID: ' + @business.objectId], "#{folder}/Businesses/#{new_logo_name}")
    end

    if @business.update_attributes(bp)
      redirect_to :back, notice: 'Successfully updated.'
    else
      redirect_to :back, notice: 'Failed to updated Business.'
    end
  end

  private

  def business_params
    params.require(:business).permit(:name, :billing_email, :business_phone,
      :billing_street, :billing_suite, :billing_city, :billing_state,
      :billing_zip, :sms_text, :business_url, :business_type)
  end

end
