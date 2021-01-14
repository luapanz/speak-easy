class PaymentGateway::StripeClient
  Stripe.api_key = "sk_test_01Zy4Y4PnkSKYgwh671IcRIn"

  def lookup_customer(identifier: )
    handle_client_error do
      @lookup_customer ||= Stripe::Customer.retrieve(identifier)
    end
  end

  def lookup_plan(identifier: )
    handle_client_error do
      @lookup_plan ||= Stripe::Plan.retrieve(identifier)
    end
  end

  def lookup_event(identifier: )
    handle_client_error do
      @lookup_event ||= Stripe::Event.retrieve(identifier)
    end
  end

  def create_customer!(options={})
    handle_client_error do
      p "STRIPE CREATE CUSTOMER"
      p options[:token]
      Stripe::Customer.create(email: options[:email], description: options[:name], source: options[:token])
    end
  end

  def create_plan!(product_id, options={})
    handle_client_error do
      Stripe::Plan.create(
        id: options[:id],
        amount: options[:amount],
        currency: options[:currency] || "usd",
        interval: options[:interval] || "month",
        product: product_id
      )
    end
  end

  def create_subscription!(options={} )
    handle_client_error do
      Stripe::Subscription.create(
          customer: options[:customerId],
          items: [{plan: options[:planId]}]
        )
    end
  end

  private def handle_client_error(message=nil, &block)
    begin
      yield
    rescue Stripe::StripeError => e
      p "STRIPE ERROR"
      p e
      raise PaymentGateway::StripeClientError.new("Stripe Error", exception_message: e.message)
    end
  end
end
