require './app/services/user_service'

class AgentsController < ApplicationController
  before_action :signed_in_user
  before_action :has_owner_access
  before_action :get_business
  before_action :get_subscriptions
  helper_method :sort_column, :sort_direction

  layout 'sidenav'
  def index
    @body_class = "with-sidebar show-sidebar"
    @user = @current_user

    @locations_ = Location.where(:business_id => @current_user.business_id).all

    @locations = {}
    @locations_.each { |k, v| @locations[k.objectId] = k.name }
    @roles = get_roles_select_options

    agents = User.where(:business_id => @current_user.business_id, :role => { :$in => [Role::AGENT, Role::FRIEND, Role::MANAGER, Role::HR, Role::FINANCE, Role::MARKETING]})
    @ordered_agents = agents.order(sort_column + ' ' + sort_direction)
    @agents_count = User.where(:business_id => @current_user.business_id, :role => { :$in => [Role::AGENT, Role::FRIEND, Role::MANAGER, Role::HR, Role::FINANCE, Role::MARKETING]}).count

    if params[:search].blank?
      @agents = Kaminari.paginate_array(@ordered_agents).page(params[:agents]).per(10)
    elsif params[:search]
      @results = @ordered_agents.select { |user| params[:search].downcase.include?(user.firstname.downcase) || params[:search].downcase.include?(user.lastname.downcase)}
      @agents = Kaminari.paginate_array(@results).page(params[:agents]).per(10)
    else
      #this can be deleted because of the first if statement
      @agents = Kaminari.paginate_array(agents).page(params[:agents]).per(10)
    end
    @agent = User.new
  end

  def invite
    @body_class = "with-sidebar show-sidebar"
    @user = @current_user
    @locations = Location.where(:business_id => @user.business_id, :is_active => true).all

    @invite = Invite.new

    @invite.message = '<center><h4>Welcome! We are excited to invite you to our SpeakEasy Team!</h4></center>
    <center>
    SpeakEasy is a team communication and campaign content distribution
    platform that allows you the ability to share exciting and relevant
    opportunities with your personal networks via SMS and other direct
    messaging services.
    </center>'

    @roles = get_roles_select_options

  end

  def createlink
    location = Location.find(invite_params["location_id"]);
    if params[:new_logo_photo].present?
      puts "Found PHOTO"
      path = params[:new_logo_photo]
      folder = Cloudinary.config.folder

      i = Cloudinary::Uploader.upload(path, {
          :upload_preset => 'logoUpload',
          :folder => "#{folder}/Locations"
        })

      if i['secure_url'].present?
        location.logo_url = i['secure_url']
        location.save
      end

      old_logo_name       = File.basename(location.logo_url, ".*")
      Cloudinary::Uploader.add_tag([
        'Business ID: ' + location.business_id,
        'Location ID: ' + location.objectId], "#{folder}/Locations/#{old_logo_name}")
    end

    expiration = DateTime.now.next_day(1).to_time

    if params[:enrollexpire].present?
      case params[:enrollexpire]
      when "1"
        expiration = DateTime.now.next_day(1).to_time
      when "2"
        expiration = DateTime.now.next_day(2).to_time
      when "3"
        expiration = DateTime.now.next_day(3).to_time
      else
        expiration = DateTime.now.next_day(1).to_time
      end
    else
      expiration = DateTime.now.next_day(1).to_time
    end

    params = invite_params
    if(!params["location_id"].present?)
      respond_to do |format|
        format.html {redirect_to agents_invite_url, error: "Could Not Create link"}
        format.json {render json: {object_id: "DEFAULT ID"}}
      end
    end

    @invite = Invite.new
    @invite.location_id = params["location_id"]
    @invite.message = params["message"]
    @invite.business_id = @current_user.business_id
    @invite.role = params["role"]
    @invite.logo = location.logo_url
    @invite.expiration = expiration

    if @invite.save
      respond_to do |format|
        format.json {render json: {"objectId": @invite.objectId}}
        format.html {redirect_to agents_invite_url, notice: "Link Created"}
      end
    else
      respond_to do |format|
        format.html {redirect_to agents_invite_url, error: "Unabled to Create Link"}
        format.json {render json: agents_invite_url}
      end
    end
  end

  def new
    @body_class = "with-sidebar show-sidebar"
    @user = @current_user
    @agent = User.new
    @agent.role = Role::AGENT

    @agentCount = User.where(:business_id => @current_user.business_id, :role => { :$in => [Role::AGENT, Role::FRIEND]}).count
    @locations = Location.where(:business_id => @current_user.business_id).all
    @roles = get_roles_select_options
  end

  def createMulti(csv)
    ap = team_member_params

    @locations = Location.where(:business_id => @current_user.business_id).all
    rows = JSON.parse(csv)

    service = UserService.new
    begin
      service.can_create_user(@current_user.business_id, rows.length, @current_user.beta_tester)
    rescue Exception => e
      flash[:error] = e.message
      redirect_to :action => :index
    end

    rows.each do |user|
      @agent = User.new(user)

      @agent.business_id = @current_user.business_id
      @agent.email.downcase!
      @agent.username = @agent.email.tr('+', '')
      @agent.send_invitation = true
      @agent.password = ('0'..'z').to_a.shuffle.first(8).join
      @agent.send_password = true
      @agent.is_active = true
      @agent.locations = [
          {
              :location_id => ap["location_id"],
              :is_active => true
          }
      ]
      @agent.location_id = nil
      @agent.role = ap["role"]

      @agent.save
    end

    redirect_to :action => :index
  end

  def create
    @body_class = "with-sidebar show-sidebar"
    @user = @current_user

    ap = team_member_params
    ap.delete(:agentCount)

    email = ap["email"]
    phone = ap["phone"]

    service = UserService.new

    if params[:user][:csv_import].present?
      rows = JSON.parse(params[:user][:csv_import])
      rows.each do |user|
        agent = User.new(user)
        service.send_email_invite(agent.firstname, agent.lastname, agent.email, @user.business_id, ap["location_id"], @user.firstname + " " + @user.lastname)
      end
      flash[:notice] = 'Successfully Invited.'
      redirect_to :agents
    elsif email.present?
      begin
        service.send_email_invite(ap["firstname"], ap["lastname"], email, @user.business_id, ap["location_id"], @user.firstname + " " + @user.lastname)
        flash[:notice] = 'Successfully Invited.'
        redirect_to :agents
      rescue Exception => e
        flash[:error] = 'Unable to add User'
        redirect_to :action => :new
      end
    elsif phone.present?
      begin
        service.send_sms_invite(ap["phone"], @user.business_id, ap["location_id"])
        flash[:notice] = 'Successfully created.'
        redirect_to :agents
      rescue Exception => e
        flash[:error] = 'Unable to add User'
        redirect_to :action => :new
      end
    else
      flash[:error] = 'Must enter Email or Phone Number'
      redirect_to :action => :new
    end
  end

  def update
    @body_class = "with-sidebar show-sidebar"
    @user = @current_user
    @locations = Location.where(:business_id => @current_user.business_id).all

    @agent = User.find(params[:id])

    if @agent.business_id != @current_user.business_id
      not_found
    end

    if params[:user][:photo].present?
      path = params[:user][:photo].path
      folder = Cloudinary.config.folder
      name_tag = @agent.firstname + " " + @agent.lastname

      if @agent.photo_url.present?
        old_photo_url = File.basename(@agent.photo_url, ".*")
        d = Cloudinary::Api.delete_resources(["#{folder}/Agents/#{old_photo_url}"])
        @agent.photo_url = "" if d["deleted"]["#{folder}/Agents/#{old_photo_url}"] == "deleted"
      end

      i = Cloudinary::Uploader.upload(path, {
          :upload_preset => 'agentUpload',
          :folder => "#{folder}/Agents",
      })

      if i['secure_url'].present?
        @agent.photo_url = i['secure_url']
      end

      new_photo_url = File.basename(@agent.photo_url, ".*")
      Cloudinary::Uploader.add_tag([
                                       name_tag,
                                       'Business ID: ' + @agent.business_id,
                                       'User ID: ' + @agent.objectId], "#{folder}/Agents/#{new_photo_url}")
    end

    ap = team_member_params
    ap.delete(:agentCount)
    @agent.is_active = ActiveRecord::Type::Boolean.new.type_cast_from_user(ap[:is_active])

    puts "ACTIVE:"
    puts @agent.is_active

    ap[:locations] = [
        {
            :location_id => ap["location_id"],
            :is_active => ActiveRecord::Type::Boolean.new.type_cast_from_user(ap[:is_active])
        }
    ]

    if @agent.update_attributes(ap)
      flash[:success] = 'Successfully updated.'
      redirect_to :agents
    else
      flash[:error] = 'Failed to update Team Member.'
      redirect_to :action => :edit
    end
  end

  def edit
    @body_class = "with-sidebar show-sidebar"
    @user = @current_user

    @locations = Location.where(:business_id => @current_user.business_id).all
    @agent = User.find(params[:id])
    if @agent.locations.present?
      @agent.location_id = @agent.locations[0]["location_id"]
    end

    puts "AGENT ROLE: "
    puts @agent.role

    if @agent.business_id != @current_user.business_id
      not_found
    end

    @roles = get_roles_select_options
  end

  private

  def team_member_params
    params.require(:user).permit(:username, :firstname, :lastname, :phone, :role, :email, :password, :location_id, :is_active, :pn)
  end

  def invite_params
    params.require(:invite).permit(:location_id, :message, :role)
  end

  def get_roles_select_options
    [
        [Role::get_role_label(Role::AGENT), Role::AGENT],
        [Role::get_role_label(Role::MANAGER), Role::MANAGER],
        [Role::get_role_label(Role::MARKETING), Role::MARKETING],
        [Role::get_role_label(Role::HR), Role::HR],
        [Role::get_role_label(Role::FINANCE), Role::FINANCE]
    ]
  end

  def sort_column
    params[:sort] || "name"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
end
