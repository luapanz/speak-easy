class LocationsController < ApplicationController
  before_action :signed_in_user
  before_action :has_owner_access
  before_action :get_business
  before_action :get_subscriptions

  layout 'sidenav'
  def index
    @body_class = "with-sidebar show-sidebar"
    @user = @current_user
    @active_locations = Kaminari.paginate_array(Location.where(:business_id => @current_user.business_id, :is_active => true)).page(params[:active]).per(8)
    @inactive_locations = Kaminari.paginate_array(Location.where(:business_id => @current_user.business_id, :is_active => false)).page(params[:inactive]).per(8)

    @location_count = Location.where(:business_id => @current_user.business_id, :is_active => true).count
  end

  def new
    @body_class = "with-sidebar show-sidebar"
    @user = @current_user
    @location = Location.new
  end

  def create
    lp = location_params
    lp[:is_active]   = ActiveRecord::Type::Boolean.new.type_cast_from_user(location_params[:is_active])
    lp[:is_virtual]  = ActiveRecord::Type::Boolean.new.type_cast_from_user(location_params[:is_virtual])
    @location = Location.new(lp)
    @location.business_id = @current_user.business_id

    if params[:edit_cropped_photo].present?
      path = params[:edit_cropped_photo]
      folder = Cloudinary.config.folder

      i = Cloudinary::Uploader.upload(path, {:upload_preset => 'logoUpload',
        :folder => "#{folder}/Locations"})

      if i['secure_url'].present?
        @location.logo_url        = i['secure_url']
      end
    end

    if @location.save
      if @location.objectId.present? && params[:location][:logo].present? && i['secure_url'].present?
        old_logo_name       = File.basename(@location.logo_url, ".*")
        Cloudinary::Uploader.add_tag([
          'Business ID: ' + @location.business_id,
          'Location ID: ' + @location.objectId], "#{folder}/Locations/#{old_logo_name}")
      end

      redirect_to :locations, notice: 'Successfully created.'
    else
      redirect_to edit_location_path(@location), notice: 'Failed to create new location.'
      return render :new
    end
  end

  def update
    @location = Location.find(params[:id])

    if @location.business_id != @current_user.business_id
      not_found
    end
    lp = location_params

    lp[:is_active]  = ActiveRecord::Type::Boolean.new.type_cast_from_user(location_params[:is_active])
    lp[:is_virtual] = ActiveRecord::Type::Boolean.new.type_cast_from_user(location_params[:is_virtual])

    if params[:edit_cropped_photo].present?
      path    = params[:edit_cropped_photo]
      folder  = Cloudinary.config.folder

      if @location.logo_url.present?
        old_logo_name       = File.basename(@location.logo_url, ".*")
        d                   = Cloudinary::Api.delete_resources( ["#{folder}/Locations/#{old_logo_name}"] )
        @location.logo_url  = "" if d["deleted"]["#{folder}/Locations/#{old_logo_name}"] == "deleted"
      end

      i = Cloudinary::Uploader.upload(path, {
          :upload_preset => 'logoUpload',
          :folder => "#{folder}/Locations"
        })

      if i['secure_url'].present?
        @location.logo_url = i['secure_url']
      end

      new_logo_name = File.basename(@location.logo_url, ".*")
      Cloudinary::Uploader.add_tag([
        'Business ID: ' + @location.business_id,
        'Location ID: ' + @location.objectId], "#{folder}/Locations/#{new_logo_name}")
    end

    if @location.update_attributes(lp)
      flash[:success] = 'Successfully updated.'
      redirect_to :locations
    else
      flash[:error] = 'Failed to update location.'
      redirect_to :action => :edit
    end

  end

  def edit
    @body_class = "with-sidebar show-sidebar"
    @user = @current_user
    @location = Location.find(params[:id])
  end

  private

  def location_params
    params.require(:location).permit(:name, :phone, :street, :suite, :state,
      :zip, :city, :is_active, :url, :is_virtual, :country)
  end
end
