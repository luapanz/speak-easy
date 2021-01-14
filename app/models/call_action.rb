class CallAction < BaseModel
  # validates_presence_of :name

  fields :name, :weight

  def self.parse_class_name
    'call_action'
  end

  def self.model_base_uri
    load_settings
    @@settings["parse_server"] + "/#{model_name_uri}"
  end
end