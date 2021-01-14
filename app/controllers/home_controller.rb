require './app/services/user_service'

class HomeController < ApplicationController
  before_action :signed_in_user
  before_action :has_owner_access
  before_action :get_business
  before_action :get_subscriptions

  layout 'sidenav'

  def dashboard
    @body_class = "with-sidebar show-sidebar"
    @user = @current_user

    @locations     = Location.where(:business_id => @user.business_id).all
    user = User.find(session[:user_id])

    @agentCount = User.where(:business_id => @current_user.business_id, :is_active => true).count

    # Because parse class name differs from our rails class name
    # business ≠ Business
    bp = @business.to_pointer

    bp.each { |k, v| bp[k] = v.downcase if k == 'className'; }

    @coupon_summ  = Hash.new
    @campaigns = Campaign.where(:business_point => bp).order('createdAt DESC')

    @shares = 0
    @engagements = 0
    @conversions = 0

    @campaigns.each do |o|
      if Date.today.at_beginning_of_month <= Time.parse(o.createdAt)
        @recipients = Recipients.where(:offer_point => {"__type":"Pointer","className":"offer","objectId":o.objectId})
        if @recipients.length > 0
          @recipients.each do |recip|
            unique_user = UniqueRecipient.where(:redemption_pointer => {"__type":"Pointer","className":"recipients","objectId":recip.objectId})
            if unique_user.length > 0
              unique_user.each do |unique|
                @shares = @shares + 1
                @engagements = @engagements + unique.engagements
                if unique.conversions.present?
                  @conversions = @conversions + unique.conversions
                end
              end
            end
          end
        end
      end
    end
  end
end
