class Invite < BaseModel
  fields :objectId, :location_id, :business_id, :role, :message, :logo, :expiration, :dynamic_link

  def self.model_base_uri
    load_settings
    @@settings["parse_server"] + "/#{model_name_uri}"
  end

  def self.parse_class_name
    'invite'
  end

end
