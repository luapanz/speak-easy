class Subscription < BaseModel

  fields :object_id, :wc_id, :wc_customer_id, :product_id, :product_name, :quantity, :status


  def self.model_base_uri
    load_settings
    @@settings["parse_server"] + "/#{model_name_uri}"
  end

  def self.parse_class_name
    'subscriptions'
  end
end