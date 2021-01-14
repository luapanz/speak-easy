require './app/services/user_service'

class CampaignsController < ApplicationController
  before_action :signed_in_user
  before_action :has_owner_access
  before_action :get_business
  before_action :get_subscriptions

  layout 'sidenav'

  def show
    @body_class = "with-sidebar show-sidebar"
    @user = @current_user
    @agentRole = Role::AGENT
    @marketRole = Role::MARKETING
    @ownerRole = Role::OWNER
    @friendRole = Role::FRIEND
    @hrRole = Role::HR
    @financeRole = Role::FINANCE
    @managerRole = Role::MANAGER
    @campaign

    begin
      @campaign = Campaign.find(params[:id])
      @all_locations     = Location.where(:business_id => @user.business_id, :is_active => true).all
      @locations = {}
      @all_locations.each {|v| @locations[v.objectId] = v.name }

      @reach = 0;
      @total_engagements = 0;
      @conversions = 0

      @agents = User.where(:business_id => @user.business_id)
      @team_agents = User.where(:business_id => @user.business_id, :role => { :$in => [Role::AGENT, Role::FRIEND]}, :is_active => true).all
      @headquarters = User.where(:business_id => @user.business_id, :role => { :$in => [Role::MARKETING, Role::HR, Role::FINANCE, Role::MANAGER]}, :is_active => true)
      @agent_names = Hash.new

      zips = []

      android = 0
      ios = 0
      other = 0

      @coupons = Coupon.where(:offer_id => @campaign.objectId).all
      @coupons.each do |c|

        agent = @agents.select {|a| a.objectId == c.agent_id }
        if agent.present?
          if !@agent_names.key?(c.agent_id)
            @agent_names[c.agent_id] = {
              firstname: agent[0].firstname,
              lastname: agent[0].lastname,
              reach: 0,
              engagements: 0,
              conversions: 0
            }
          end

          @recipients = Recipients.where(:offer_point => {"__type":"Pointer","className":"offer","objectId":@campaign.objectId}, :createdBy => {"__type":"Pointer","className":"_User","objectId":c.agent_id})
          if @recipients
            if @recipients.length > 0
              @recipients.each do |recip|
                unique_user = UniqueRecipient.where(:redemption_pointer => {"__type":"Pointer","className":"recipients","objectId":recip.objectId})
                if unique_user
                  if unique_user.length > 0
                    unique_user.each do |unique|
                      @agent_names[c.agent_id][:reach] = @agent_names[c.agent_id][:reach] + 1
                      @agent_names[c.agent_id][:engagements] = @agent_names[c.agent_id][:engagements] + unique.engagements
                      if unique.conversions.present?
                        @agent_names[c.agent_id][:conversions] = @agent_names[c.agent_id][:conversions] + unique.conversions
                      end
                      zips.push(unique.postal)
                      if unique.os == 'Android'
                        android = android + 1
                      elsif unique.os == 'IPhone'
                        ios = ios + 1
                      else
                        other = other +1
                      end
                    end
                  end
                end
              end
            end
          end

          if @agent_names[c.agent_id][:reach] < 1
            @agent_names[c.agent_id][:reach] = c.sent_coupons.to_i
            @agent_names[c.agent_id][:engagements] = c.viewed_coupons.to_i
            @agent_names[c.agent_id][:conversions] = c.success.to_i
          end
        end
      end

      @agent_names.each do |key, value|
        @reach = @reach + value[:reach]
        @total_engagements = @total_engagements + value[:engagements]
        @conversions = @conversions + value[:conversions]
      end

      zipshash = Hash.new(0)
      zips.each do |zip|
        zipshash[zip] += 1
      end

      zipslabel = []
      zipsquanity = []

      zipshash.each do |key, value|
        zipslabel.push(key)
        zipsquanity.push(value)
      end

      @data = {
        labels: ["iPhone","Android","Other"],
        datasets: [
          {
            backgroundColor: [
              "rgba(102,204,255,0.5)",
              "rgba(153,255,51,0.5)",
              "rgba(102,153,153,0.5)"
            ],
            strokeColor: "rgba(220,100,220,1)",
            pointColor: "rgba(210,100,220,1)",
            pointStrokeColor: "#fff",
            data: [ios,android,other]
          },
        ]
      }
      @zipdata = {
        labels: zipslabel,
        datasets: [
          {
            backgroundColor: [
              "rgba(100,181,246 ,1)",
              "rgba(255,235,59 ,1)",
              "rgba(123,31,162 ,1)",
              "rgba(96,125,139 ,1)",
              "rgba(244,67,54 ,1)"
            ],
            strokeColor: "rgba(220,100,220,1)",
            pointColor: "rgba(210,100,220,1)",
            pointStrokeColor: "#fff",
            data: zipsquanity
          },
        ]
      }
      @options = {}

    rescue
      # handle error
      @campaign = nil
    end


  end

  def new
    @body_class = "with-sidebar show-sidebar"
    @user = @current_user
    @agentRole = Role::AGENT
    @marketRole = Role::MARKETING
    @ownerRole = Role::OWNER
    @friendRole = Role::FRIEND
    @hrRole = Role::HR
    @financeRole = Role::FINANCE
    @managerRole = Role::MANAGER

    @campaign = Campaign.new
    @campaign.coupons = nil
    defaultCoupons = ParseResource::ParseConfig.config['params']['coupons_per_agent']
    @campaign.run_interval = DateTime.current
    @campaign.custom_action = true
    @campaign.upcoming = true
    @campaign.send_owner = true
    @age_restriction = ParseResource::ParseConfig.config['params']['offer_age_restriction']
    #@restrictions = ParseRes      puts "AGENTS!!!"
    @restrictions = "None"
    user          = User.find(session[:user_id])
    @locations = Location.where(:business_id => user.business_id, :is_active => true).all
    @agents = User.where(:business_id => user.business_id, :role => { :$in => [Role::AGENT, Role::FRIEND]}, :is_active => true)
    @headquarters = User.where(:business_id => user.business_id, :role => { :$in => [Role::MARKETING, Role::HR, Role::FINANCE, Role::MANAGER]}, :is_active => true)
  end

  def index
    @body_class = "with-sidebar show-sidebar"
    @user = @current_user
    @coupon_summ  = Hash.new
    user          = User.find(session[:user_id])
    locations     = Location.where(:business_id => user.business_id).all

    @locations = {}
    locations.each {|v| @locations[v.objectId] = v.name }

    # Because parse class name differs from our rails class name
    # business ≠ Business
    bp = @business.to_pointer

    bp.each { |k, v| bp[k] = v.downcase if k == 'className'; }

    @allcampaigns = Campaign.where(:business_point => bp).order('createdAt DESC')



    activecampaigns = active_campaigns_method(@allcampaigns)
    @active_campaigns = Kaminari.paginate_array(activecampaigns).page(params[:active]).per(10)
    @active_campaigns.each do |o|

      if !@coupon_summ.key?(o.objectId)
        @coupon_summ[o.objectId] = {
            num_coupons: 0,
            sent_coupons: 0,
            unsent: 0,
            viewed_coupons: 0,
            success: 0,
            reach: 0,
            engagements: 0,
            conversions: 0
        }
      end

      @recipients = Recipients.where(:offer_point => {"__type":"Pointer","className":"offer","objectId":o.objectId})

      if @recipients
        if @recipients.length > 0
          @recipients.each do |recip|
            unique_user = UniqueRecipient.where(:redemption_pointer => {"__type":"Pointer","className":"recipients","objectId":recip.objectId})
            if unique_user
              if unique_user.length > 0
                unique_user.each do |unique|
                  @coupon_summ[o.objectId][:reach] = @coupon_summ[o.objectId][:reach] + 1
                  @coupon_summ[o.objectId][:engagements] = @coupon_summ[o.objectId][:engagements] + unique.engagements
                  if unique.conversions.present?
                    @coupon_summ[o.objectId][:conversions] = @coupon_summ[o.objectId][:conversions] + unique.conversions
                  end
                end
              end
            end
          end
        end
      end
    end


    pastcampaigns = past_campaigns_method(@allcampaigns)
    @past_campaigns = Kaminari.paginate_array(pastcampaigns).page(params[:past]).per(10)
    @past_campaigns.each do |o|
      if !@coupon_summ.key?(o.objectId)
        @coupon_summ[o.objectId] = {
            num_coupons: 0,
            sent_coupons: 0,
            unsent: 0,
            viewed_coupons: 0,
            success: 0,
            reach: 0,
            engagements: 0,
            conversions: 0
        }
      end

      @recipients = Recipients.where(:offer_point => {"__type":"Pointer","className":"offer","objectId":o.objectId})

      if @recipients
        if @recipients.length > 0
          @recipients.each do |recip|
            unique_user = UniqueRecipient.where(:redemption_pointer => {"__type":"Pointer","className":"recipients","objectId":recip.objectId})
            if unique_user
              if unique_user.length > 0
                unique_user.each do |unique|
                  @coupon_summ[o.objectId][:reach] = @coupon_summ[o.objectId][:reach] + 1
                  @coupon_summ[o.objectId][:engagements] = @coupon_summ[o.objectId][:engagements] + unique.engagements
                  if unique.conversions.present?
                    @coupon_summ[o.objectId][:conversions] = @coupon_summ[o.objectId][:conversions] + unique.conversions
                  end
                end
              end
            end
          end
        end
      end

      Coupon.where(:offer_id => o.objectId).each do |c|
        if @coupon_summ[c.offer_id].present?
            @coupon_summ[c.offer_id][:num_coupons] = @coupon_summ[c.offer_id][:num_coupons] + c.num_coupons.to_i
            @coupon_summ[c.offer_id][:sent_coupons] = @coupon_summ[c.offer_id][:sent_coupons] + c.sent_coupons.to_i
            @coupon_summ[c.offer_id][:viewed_coupons] = @coupon_summ[c.offer_id][:viewed_coupons] + c.viewed_coupons.to_i
            @coupon_summ[c.offer_id][:success] = @coupon_summ[c.offer_id][:success] + c.success.to_i
        end
      end
    end

    futurecampaigns = future_campaigns_method(@allcampaigns)
    @future_campaigns = Kaminari.paginate_array(futurecampaigns).page(params[:future]).per(10)
    # @future_campaigns.each do |o|
    #   Coupon.where(:offer_id => o.objectId).each do |c|
    #     if @coupon_summ[c.offer_id].present?
    #         #@coupon_summ[c.offer_id].each {|k,v| @coupon_summ[c.offer_id][k] += c.send(k).to_i }
    #         @coupon_summ[c.offer_id] = {
    #             num_coupons: 0,
    #             sent_coupons: 0,
    #             unsent: 0,
    #             viewed_coupons: 0,
    #             success: 0
    #         }
    #     else
    #         @coupon_summ[c.offer_id] = {
    #             num_coupons: c.num_coupons.to_i,
    #             sent_coupons: c.sent_coupons.to_i,
    #             unsent: c.num_coupons.to_i - c.sent_coupons.to_i,
    #             viewed_coupons: c.viewed_coupons.to_i,
    #             success: c.success.to_i
    #         }
    #     end
    #   end
    # end
  end

  def create
    @age_restriction = ParseResource::ParseConfig.config['params']['offer_age_restriction']
    #@restrictions = ParseResource::ParseConfig.config['params']['offer_restrictions']
    @restrictions = "None"
    user          = User.find(session[:user_id])
    @locations     = Location.where(:business_id => user.business_id, :is_active => true).order('createdAt DESC')
    @agents = User.where(:business_id => user.business_id, :role => { :$in => [Role::AGENT, Role::FRIEND]})
    agentParams = params['agents']
    cp = campaign_params

    locations = []
    agents = []
    if !agentParams.nil?
      agentParams.each do |location|
        locations = locations + [location[0]]
        location[1].each do |agent|
          agents = agents + [agent]
        end
      end
    end

    locations.delete('Headquarters')

    if campaign_params[:send_owner]
      agents   = agents - [""] + [user.objectId]
      if !locations.include?(cp[:owner_location])
        locations = locations + [cp[:owner_location]]
      end
    end

    json_string = campaign_params[:details]
    details = json_string.gsub("\"value\"", "\"insert\"")
    details.gsub! '{"bold":true}', '{"b":true}'
    details.gsub! '{"italic":true}', '{"i":true}'
    details.gsub! '{"bullet":true}', '{"block":"ul"}'
    details.gsub! '{"list":true}', '{"block":"ol"}'
    details.gsub! '{"list":"bullet"}', '{"block":"ul"}'
    details.gsub! '{"list":"ordered"}', '{"block":"ol"}'
    details.gsub! '"link"', '"a"'

    json_con = campaign_params[:offer_condition]
    conditions = json_con.gsub("\"value\"", "\"insert\"")
    conditions.gsub! '{"bold":true}', '{"b":true}'
    conditions.gsub! '{"italic":true}', '{"i":true}'
    conditions.gsub! '{"bullet":true}', '{"block":"ul"}'
    conditions.gsub! '{"list":true}', '{"block":"ol"}'
    conditions.gsub! '{"list":"ordered"}', '{"block":"ol"}'
    conditions.gsub! '{"list":"bullet"}', '{"block":"ul"}'
    conditions.gsub! '"link"', '"a"'


    cp[:details] = details
    cp[:offer_condition] = conditions
    cp[:run_date]   = DateTime.strptime(campaign_params[:run_date], '%m/%d/%Y %I:%M %P')
    cp[:start_date] = nil
    if campaign_params[:start_date].present?
      cp[:start_date]   = DateTime.strptime(campaign_params[:start_date], '%m/%d/%Y %I:%M %P')
    end
    cp[:location_ids] = locations
    cp[:agent_ids]   = agents
    cp[:num_agents] = campaign_params[:num_agents].to_f
    num_coupons = campaign_params[:num_coupons].to_f
    cp[:num_coupons] = num_coupons ? num_coupons * (cp[:num_agents] + 1) : nil
    cp[:add_upcoming] = campaign_params[:add_upcoming].to_s == 'true'
    cp[:isOfferCompleted] = false
    cp[:offer_type_id] = nil
    cp[:custom_action] = true

    if !cp[:cta].present?
      cp[:cta] = "Check It Out"
      cp[:cta_text] = "Check It Out"
    else
      cp[:cta_text] = cp[:cta]
    end

    cp[:createdBy_point] = {"__type" => "Pointer",
                            "className" => "_User",
                            "objectId" => user.objectId}
    cp.delete(:coupons)
    cp.delete(:select_all_agents)
    cp.delete(:send_owner)
    cp.delete(:upcoming)
    cp.delete(:run_interval)
    cp.delete(:limited_coupons)
    #cp.delete(:owner_location)
    bp = @business.to_pointer
    bp.each { |k, v| bp[k] = v.downcase if k == 'className'; }
    cp[:business_point] = bp
    @campaign = Campaign.new(cp)

    if params[:cropped_photo].present?
      path = params[:cropped_photo]
      folder = Cloudinary.config.folder

      i = Cloudinary::Uploader.upload(path, {:upload_preset => 'offerUpload',
                                             :folder => "#{folder}/Offers"})

      if i['secure_url'].present?
        @campaign.photo_url        = i['secure_url']
      end
    end

    if @campaign.save
      agents.each do |agent|
        @coupon = Coupon.new({
           'agent_id'=> agent,
           'offer_id'=> @campaign.objectId,
           'num_coupons'=> num_coupons,
           'success'=> 0,
           'total_coupons'=> 0,
           'viewed_coupons'=> 0,
           'sent_coupons'=> 0
       })
        @coupon.save
      end

      flash[:notice] = 'Successfully created.'
    else
      flash[:error] = 'Failed to create new campaign.' + @campaign.errors.full_messages.to_s
      return render :new
    end

    redirect_to :action => :index
  end

  def update
    @old_camp = Campaign.find(params[:id])
    @campaign = Campaign.new
    @user = @current_user

    @locations     = Location.where(:business_id => @user.business_id).all
    @agents = User.where(:business_id => @user.business_id, :role => { :$in => [Role::AGENT, Role::FRIEND]})
    agentParams = params['agents']

    locations = []
    agents = []
    if !agentParams.nil?
      agentParams.each do |location|
        locations = locations + [location[0]]
        location[1].each do |agent|
          agents = agents + [agent]
        end
      end
    end

    locations.delete('Headquarters')

    if params[:send_owner]
      agents   = agents - [""] + [@user.objectId]
    end

    cp = campaign_params
    cp[:run_date]   = Date.strptime(campaign_params[:run_interval][13,23], '%m/%d/%Y').to_datetime
    cp[:start_date] = Date.strptime(campaign_params[:run_interval][0,10], '%m/%d/%Y').to_datetime
    cp[:agent_ids]   = agents
    cp[:num_agents] = campaign_params[:num_agents].to_f
    num_coupons = campaign_params[:num_coupons].to_f
    cp[:num_coupons] = num_coupons ? num_coupons * (cp[:num_agents] + 1) : nil

    bp = @business.to_pointer
    bp.each { |k, v| bp[k] = v.downcase if k == 'className'; }
    cp[:business_point] = bp

    @campaign.video_thumb_url = @old_camp.video_thumb_url
    @campaign.run_date = cp[:run_date]
    @campaign.photo_url = @old_camp.photo_url
    @campaign.details = @old_camp.details
    @campaign.custom_action = @old_camp.custom_action
    @campaign.coupon_code = @old_camp.coupon_code
    @campaign.restrictions = "None"
    @campaign.start_date = cp[:start_date]
    @campaign.redirect_url = @old_camp.redirect_url
    @campaign.location_ids = cp[:location_ids]
    @campaign.cta = @old_camp.cta
    @campaign.createdBy_point = {"__type" => "Pointer",
                            "className" => "_User",
                            "objectId" => @user.objectId}
    @campaign.business_point = cp[:business_point]
    @campaign.offer_title = @old_camp.offer_title
    @campaign.isOfferCompleted = false
    @campaign.cta_text = @old_camp.cta_text
    @campaign.agent_ids = agents
    @campaign.age = @old_camp.age
    @campaign.num_coupons = cp[:num_coupons]

    if @campaign.save
      agents.each do |agent|
        @coupon = Coupon.new({
                                 'agent_id'=> agent,
                                 'offer_id'=> @campaign.objectId,
                                 'num_coupons'=> 0,
                                 'success'=> 0,
                                 'total_coupons'=> 0,
                                 'viewed_coupons'=> 0,
                                 'sent_coupons'=> 0
                             })
        @coupon.save
      end
      flash[:success] = 'Successfully updated.'
      redirect_to :action => :index
    else
      flash[:error] = 'Failed to update location.'
      redirect_to :back
    end
  end

  def edit
    @campaign = Campaign.find(params[:id])
  end


  def past_campaigns
    @body_class = "with-sidebar show-sidebar"
    @user = @current_user
    @coupon_summ  = Hash.new
    user          = User.find(session[:user_id])
    locations     = Location.where(:business_id => user.business_id).all

    @locations = {}
    locations.each {|v| @locations[v.objectId] = v.name }

    # Because parse class name differs from our rails class name
    # business ≠ Business
    bp = @business.to_pointer

    bp.each { |k, v| bp[k] = v.downcase if k == 'className'; }

    @allcampaigns = Campaign.where(:business_point => bp).order('createdAt DESC')

    pastcampaigns = past_campaigns_method(@allcampaigns)
    @past_campaigns = Kaminari.paginate_array(pastcampaigns).page(params[:past]).per(16)
  end

  def current_campaigns
    @body_class = "with-sidebar show-sidebar"
    @user = @current_user
    @coupon_summ  = Hash.new
    user          = User.find(session[:user_id])
    locations     = Location.where(:business_id => user.business_id).all

    @locations = {}
    locations.each {|v| @locations[v.objectId] = v.name }

    bp = @business.to_pointer
    bp.each { |k, v| bp[k] = v.downcase if k == 'className'; }

    @allcampaigns = Campaign.where(:business_point => bp).order('createdAt DESC')

    activecampaigns = active_campaigns_method(@allcampaigns)
    @active_campaigns = Kaminari.paginate_array(activecampaigns).page(params[:page]).per(16)

    @active_campaigns.each do |o|
      Coupon.where(:offer_id => o.objectId).each do |c|
        if @coupon_summ[c.offer_id].present?
            #@coupon_summ[c.offer_id].each {|k,v| @coupon_summ[c.offer_id][k] += c.send(k).to_i }
            @coupon_summ[c.offer_id] = {
                num_coupons: 0,
                sent_coupons: 0,
                unsent: 0,
                viewed_coupons: 0,
                success: 0
            }
        else
            @coupon_summ[c.offer_id] = {
                num_coupons: c.num_coupons.to_i,
                sent_coupons: c.sent_coupons.to_i,
                unsent: c.num_coupons.to_i - c.sent_coupons.to_i,
                viewed_coupons: c.viewed_coupons.to_i,
                success: c.success.to_i
            }
        end
      end
    end
  end

  def future_campaigns
    @body_class = "with-sidebar show-sidebar"
    @user = @current_user
    @coupon_summ  = Hash.new
    user          = User.find(session[:user_id])
    locations     = Location.where(:business_id => user.business_id).all

    @locations = {}
    locations.each {|v| @locations[v.objectId] = v.name }

    bp = @business.to_pointer
    bp.each { |k, v| bp[k] = v.downcase if k == 'className'; }

    @allcampaigns = Campaign.where(:business_point => bp).order('createdAt DESC')

    futurecampaigns = future_campaigns_method(@allcampaigns)
    @future_campaigns = Kaminari.paginate_array(futurecampaigns).page(params[:page]).per(16)
  end


  private

  def get_roles_select_options
    [
        [Role::get_role_label(Role::AGENT), Role::AGENT],
        [Role::get_role_label(Role::MANAGER), Role::MANAGER],
        [Role::get_role_label(Role::MARKETING), Role::MARKETING],
        [Role::get_role_label(Role::HR), Role::HR],
        [Role::get_role_label(Role::FINANCE), Role::FINANCE]
    ]
  end

  def campaign_params
    params.require(:campaign).permit(:offer_title, :run_date, :details, :coupon_code, :offer_condition, :age,
                                     :restrictions, :agent_ids, :business_point, :num_agents, :offer_type_id,
                                     :num_coupons, :isOfferCompleted, :offerOff, :coupons, :add_upcoming, :target_audience,
                                     :custom_action, :cta, :cta_text, :redirect_url, :start_date, :activate_date, :run_interval,
                                     :pixel_id, :limited_coupons, :video_url, :video_thumb_url, :send_owner, :owner_location,
                                     :location_ids => [], :select_all_agents => [], :agent_ids => [], :upcoming => [], )
  end

  def past_campaigns_method(allcampaigns)
    past_campaigns = []

    allcampaigns.each do |campaign|
      if campaign.run_date < DateTime.now
        past_campaigns << campaign
      end
    end

    return past_campaigns
  end

  def active_campaigns_method(allcampaigns)
    active_campaigns = []

    allcampaigns.each do |campaign|
      if (campaign.start_date && (campaign.start_date < DateTime.now)) && (campaign.run_date && (campaign.run_date > DateTime.now))
          active_campaigns << campaign
      end
    end

    return active_campaigns
  end

  def future_campaigns_method(allcampaigns)
    future_campaigns = []

    allcampaigns.each do |campaign|
       if (campaign.start_date && (campaign.start_date > DateTime.now)) && (campaign.run_date && (campaign.run_date > DateTime.now))
        future_campaigns << campaign
      end
    end

    return future_campaigns
  end

end
