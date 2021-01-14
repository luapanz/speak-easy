class SubscriptionPlan < BaseModel
  fields :name, :cost, :users, :physical, :virtual, :objectId

  def self.model_base_uri
    load_settings
    @@settings["parse_server"] + "/#{model_name_uri}"
  end

  def self.parse_class_name
    'payment_plans'
  end

end
