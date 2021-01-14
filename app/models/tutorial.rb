class Tutorial < BaseModel
  # validates_presence_of :name

  fields :show_app, :show_fans, :show_team, :show_location, :show_business, :business_id


  def self.model_base_uri
    load_settings
    @@settings["parse_server"] + "/#{model_name_uri}"
  end

  # belongs_to :offer

  def self.parse_class_name
    'tutorial'
  end
end
