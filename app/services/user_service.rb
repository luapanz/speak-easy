require 'api_request_service'

class UserService
  def resend_verification_email(username)
    request_service = ApiRequestService.new
    response = request_service.call_cloud_function('User:resendEmailVerification', {
        :username => username
    })
    if response.code == "200"
      {}
    else
      if response.code == "400"
        raise "Email is already verified"
      else
        raise "Unknown error"
      end
    end
  end

  def can_create_campaign(business_id, beta_tester)
    if beta_tester
      {}
    else
      request_service = ApiRequestService.new
      response = request_service.call_cloud_function('User:canCreateCampaign', {
          :business_id => business_id
      })
      if response.code == "200"
        {}
      else
        if response.code == "400"
          raise "You have exceeded your monthly campaign limit. Please <a href='https://justspeakeasy.com/subscription/growth/'>upgrade to Growth Plan</a> to create unlimited campaigns."
        else
          raise "Unknown error"
        end
      end
    end
  end

  def can_send_coupon(business_id, beta_tester)
    if beta_tester
      {}
    else
      request_service = ApiRequestService.new
      response = request_service.call_cloud_function('User:canSendCoupon', {
          :business_id => business_id
      })
      if response.code == "200"
        {}
      else
        if response.code == "400"
          raise "You do not have anymore licenses left. Please <a href='https://justspeakeasy.com/pricing/'>upgrade your subscription</a>."
        else
          raise "Unknown error"
        end
      end
    end
  end

  def can_create_user(business_id, to_create_num, beta_tester)
    if beta_tester
      {}
    else
      request_service = ApiRequestService.new
      response = request_service.call_cloud_function('User:canCreateUser', {
          :business_id => business_id,
          :to_create_num => to_create_num
      })
      if response.code == "200"
        {}
      else
        if response.code == "400"
          raise "You do not have anymore licenses left. Please <a href='https://justspeakeasy.com/pricing/'>upgrade your subscription</a>."
        else
          raise "Unknown error"
        end
      end
    end
  end

  def has_active_subscriptions(business_id)
    request_service = ApiRequestService.new
    response = request_service.call_cloud_function('User:subscriptionIsActive', {
        :businessId => business_id
    })
    if response.code == "200"
      {}
    else
      if response.code == "400"
        raise "Not Subscribed"
      else
        raise "Unknown error"
      end
    end
  end

  def change_user_password(oldPassword, newPassword, email)
    request_service = ApiRequestService.new
    response = request_service.call_cloud_function('User:changePasswordWithEmail', {
        :oldPassword => oldPassword,
        :newPassword => newPassword,
        :email => email
    })
    if response.code == "200"
      {}
    else
      if response.code == "400"
        raise response.message
      else
        raise response.message
      end
    end
  end

  def send_team_member_link(phoneNumber, businessId, locationId)
    request_service = ApiRequestService.new
    response = request_service.call_cloud_function("sendTeamMemberText", {
      :phoneNumber => phoneNumber,
      :businessId => businessId,
      :locationId => locationId,
      :message => "Follow the link to download SpeakEasy and setup your account. "
    })
    if response.code == "200"
      {}
    else
      raise response.message
    end
  end

  def send_sms_invite(phoneNumber, businessId, locationId)
    request_service = ApiRequestService.new
    response = request_service.call_cloud_function("sendTeamMemberText", {
      :phoneNumber => phoneNumber,
      :businessId => businessId,
      :locationId => locationId,
      :message => "You have been invited to join SpeakEasy. Use the link to check it out. "
    })
    if response.code == "200"
      {}
    else
      raise response.message
    end
  end

  def send_email_invite(firstName, lastName, email, businessId, locationId, ownerName)
    request_service = ApiRequestService.new
    response = request_service.call_cloud_function("Business:inviteTeamMember", {
      :firstName => firstName,
      :lastName => lastName,
      :email => email,
      :businessId => businessId,
      :locationId => locationId,
      :ownerName => ownerName
    })
    if response.code == "200"
      {}
    else
      raise response.message
    end
  end

  def create_subscription(token, planId, businessId)
    request_service = ApiRequestService.new
    response = request_service.call_cloud_function("Subscription:createSubscription", {
      :businessId => businessId,
      :token => token,
      :planId => planId
    })
    if response.code == "200"
      return "success"
    else
      return response.message
    end
  end

  def update_subscription(businessId, planId)
    request_service = ApiRequestService.new
    response = request_service.call_cloud_function("Subscription:updateSubscription", {
      :businessId => businessId,
      :planId => planId
    })
    if response.code == "200"
      return "success"
    else
      return response.message
    end
  end

  def cancel_subscription(businessId)
    request_service = ApiRequestService.new
    response = request_service.call_cloud_function("Subscription:cancelSubscription", {
      :businessId => businessId
    })
    if response.code == "200"
      return "success"
    else
      return response.message
    end
  end

  def activate_subscription(businessId)
    request_service = ApiRequestService.new
    response = request_service.call_cloud_function("Subscription:activateSubscription", {
      :businessId => businessId
    })
    if response.code == "200"
      return "success"
    else
      return response.message
    end
  end

  def update_users_subscription(businessId, userAmount)
    request_service = ApiRequestService.new
    response = request_service.call_cloud_function("Subscription:addOrDeleteUsers", {
      :businessId => businessId,
      :userAmount => userAmount # total user count not added user count
    })
    if response.code == "200"
      return "success"
    else
      return response.message
    end
  end

  def update_card(businessId, token)
    request_service = ApiRequestService.new
    response = request_service.call_cloud_function("Subscription:updateCard", {
      :businessId => businessId,
      :token => token
    })
    if response.code == "200"
      return "success"
    else
      return response.message
    end
  end
end
