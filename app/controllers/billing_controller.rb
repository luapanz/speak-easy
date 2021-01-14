class BillingController < ApplicationController
  before_action :signed_in_user
  before_action :has_owner_access
  before_action :get_business
  before_action :can_access_subscription_page

  layout 'sidenav'

  def index
    @body_class = "with-sidebar show-sidebar"
    @user = @current_user

    puts @user.subscription_status
    # @small_plan = SubscriptionPlan.find("18bdAdbfj4")
    @small_plan = SubscriptionPlan.find("JTMJtFnmDV") # this is mine
    @medium_plan = SubscriptionPlan.find("R904A1IYAC")
    @large_plan = SubscriptionPlan.find("IFzJFWDB9c")
    @current_plan = "Plan"
    @enterprise = false
    subscription = StripeSubscription.where(:business_point => {"__type":"Pointer","className":"business","objectId":@user.business_id}).first

    if subscription.enterprise
      @enterprise = true
    end

    @new = true
    if subscription.first_payment.present?
      @new = false
      @last_payment = subscription.last_payment.strftime("%-m/%-d/%Y")
      @plan = @small_plan
      @extra_members = 0
      if subscription.extra_members.present?
        @extra_members = subscription.extra_members
      end
    else
      @new = true
    end
  end
end
