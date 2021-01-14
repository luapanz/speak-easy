class BusinessType < BaseModel
  # validates_presence_of :name

  fields :object_id, :name

  def self.model_base_uri
    load_settings
    @@settings["parse_server"] + "/#{model_name_uri}"
  end

  def self.parse_class_name
    'business_type'
  end
end