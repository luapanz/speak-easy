class Terms < BaseModel
  # validates_presence_of :name

  fields :object_id, :text

  def self.model_base_uri
    load_settings
    @@settings["parse_server"] + "/#{model_name_uri}"
  end

  def self.parse_class_name
    'terms_of_service'
  end
end