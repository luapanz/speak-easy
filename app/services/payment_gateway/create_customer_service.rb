class PaymentGateway::CreateCustomerService < PaymentGateway::Service
  EXCEPTION_MESSAGE = "There was an error while creating the customer"
  attr_accessor :user, :token, :success

  def initialize(user:, token:)
    @user = user
    @token = token
    @success = false
  end

  def run
    begin
      client.create_customer!(
        email: user.email,
        name: user.firstname << " " << user.lastname,
        token: token
      ).tap do |customer|
          @user.stripe_id = customer.id
          @user.save
          @success = true
      end
    rescue ActiveRecord::RecordInvalid,
      PaymentGateway::ClientError => e
      raise PaymentGateway::CreateCustomerService.new(
        EXCEPTION_MESSAGE,
        exception_message: e.message
      )
    end
  end
end
