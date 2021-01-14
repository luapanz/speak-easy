class Recipients < BaseModel
  fields :objectId, :offer_point, :business_point, :createdBy

  def self.parse_class_name
    'recipients'
  end

  def self.model_base_uri
    load_settings
    @@settings["parse_server"] + "/#{model_name_uri}"
  end
end
