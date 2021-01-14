class StripeSubscription < BaseModel
  fields :active, :plan_point, :free_trial, :last_payment, :first_payment, :enterprise, :extra_members

  def self.model_base_uri
    load_settings
    @@settings["parse_server"] + "/#{model_name_uri}"
  end

  def self.parse_class_name
    'subscription'
  end

end
