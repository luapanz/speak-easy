class PaymentGateway::ServiceError < StandardError
  attr_reader :exception_message

  def initialize(message, exception_message )
    super(message)
    @exception_message = exception_message
  end
end

class PaymentGateway::CreateSubscriptionServiceError < PaymentGateway::ServiceError
end

class PaymentGateway::CreatePlanServiceError < PaymentGateway::ServiceError
end

class PaymentGateway::CreateCustomerServiceError < PaymentGateway::ServiceError
end
