class Business < BaseModel
  # validates_presence_of :name

  fields :object_id, :title, :run_date, :name, :billing_email, :business_phone,
    :billing_street, :billing_suite, :billing_city, :billing_state,
    :billing_zip, :sms_text, :business_url, :business_type, :logo_url, :coupon


  def self.model_base_uri
    load_settings
    @@settings["parse_server"] + "/#{model_name_uri}"
  end

  # belongs_to :offer

  def self.parse_class_name
    'business'
  end
end
