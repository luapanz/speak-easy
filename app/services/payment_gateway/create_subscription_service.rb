class PaymentGateway::CreateSubscriptionService < PaymentGateway::Service
  ERROR_MESSAGE = "There was an error while creating the subscription"
  attr_accessor :user, :plan, :subscription, :success

  def initialize(user:, plan:)
    @user = user
    @plan = plan
    @success = false
  end

  def run
    begin
        client.create_subscription!(
          customerId: @user.stripe_id,
          planId: @plan
        ).tap do
        self.success = true
      end
    rescue ActiveRecord::RecordInvalid,
      PaymentGateway::ClientError => e
      p "SUBSCRIPTION ERROR"
      p e
      raise PaymentGateway::CreateSubscriptionServiceError.new(
        ERROR_MESSAGE,
        exception_message: e.message
      )
    end
  end

  private def create_client_subscription
    client.create_subscription!(
      customer: payment_gateway_customer,
      plan: payment_gateway_plan,
    )
  end

  private def create_subscription
    Stripe::Subscription.create!(user: user,
      plan: plan,
      start_date: Time.zone.now.to_date,
      end_date: Time.zone.now.to_date,
      status: :active)
  end

  private def payment_gateway_customer
    create_customer_service = PaymentGateway::CreateCustomerService.new(
      user: user
    )
    create_customer_service.run
  end

  private def payment_gateway_plan
    get_plan_service = PaymentGateway::GetPlanService.new(
      plan: plan
    )
    get_plan_service.run
  end
end
