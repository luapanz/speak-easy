require './app/services/user_service'
require 'date'

class AnnouncementsController < ApplicationController
    before_action :signed_in_user
    before_action :has_owner_access
    before_action :get_business
    before_action :get_subscriptions

    layout 'sidenav'
    def new
      @body_class = "with-sidebar show-sidebar"
      @user = @current_user
      @announcement = Announcement.new
      user          = User.find(session[:user_id])
      @locations = Location.where(:business_id => user.business_id, :is_active => true).all
    end

    def create
      @body_class = "with-sidebar show-sidebar"
      @user = @current_user
      @announcement = Announcement.new
      user          = User.find(session[:user_id])
      @locations = Location.where(:business_id => user.business_id, :is_active => true).all

      ann_params = params[:announcement]
      json_string = params[:announcement][:details]
      description = json_string.gsub("\"value\"", "\"insert\"")
      an = Announcement.new(:business_point => {"__type":"Pointer","className":"business","objectId": @user.business_id})

      an.title = ann_params[:title]

      description.gsub! '{"bold":true}', '{"b":true}'
      description.gsub! '{"italic":true}', '{"i":true}'
      description.gsub! '{"bullet":true}', '{"block":"ul"}'
      description.gsub! '{"list":true}', '{"block":"ol"}'
      description.gsub! '"link"', '"a"'
      description.gsub! '{"list":"bullet"}', '{"block":"ul"}'
      description.gsub! '{"list":"ordered"}', '{"block":"ol"}'
      an.details = description

      locations = []
      ann_params[:locations].split(',').each do |location|
        if location != ''
          locations.push(location)
        end
      end
      an.location_ids = locations

      end_date = nil
      case ann_params[:run_time_frame]
      when "1 Day"
        end_date = Date.today + 1
      when "1 Week"
        end_date = Date.today + 7
      when "1 Month"
        end_date = Date.today + 30
      end
      an.end_date = end_date

      if params[:cropped_photo].present?
        path = params[:cropped_photo]
        folder = Cloudinary.config.folder

        i = Cloudinary::Uploader.upload(path, {:upload_preset => 'offerUpload',
                                               :folder => "#{folder}/Offers"})
        if i['secure_url'].present?
          an.photo_url = i['secure_url']
        end
      end

      an.createdBy_point = user.to_pointer

      if an.save
        flash[:notice] = 'Successfully created.'
        redirect_to "/home/dashboard"
      else
        flash[:error] = 'Failed to create new campaign.' + an.errors.full_messages.to_s
        puts an.errors.full_messages.to_s
        redirect_to :new
      end

    end

    def index
      @body_class = "with-sidebar show-sidebar"
      @user = @current_user
      @announcements = Kaminari.paginate_array(Announcement.where(:business_point => {"__type":"Pointer","className":"business","objectId": @user.business_id}).order('createdAt DESC')).page(params[:announcement]).per(10)
    end

end
