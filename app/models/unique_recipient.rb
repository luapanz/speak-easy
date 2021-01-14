class UniqueRecipient < BaseModel
  fields :objectId, :engagements, :city, :region, :country, :postal, :os, :redemption_pointer, :conversions, :createdAt

  def self.parse_class_name
    'unique_recipient'
  end

  def self.model_base_uri
    load_settings
    @@settings["parse_server"] + "/#{model_name_uri}"
  end
end
