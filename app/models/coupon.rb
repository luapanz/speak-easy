class Coupon < BaseModel
  fields :num_coupons, :sent_coupons, :unsent, :viewed_coupons, :success, :offer_id, :agent_id, :updatedAt

  def self.model_base_uri
    load_settings
    @@settings["parse_server"] + "/#{model_name_uri}"
  end

  def self.parse_class_name
    'coupons'
  end

end
