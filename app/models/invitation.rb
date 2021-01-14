class Invitation < BaseModel
  # validates_presence_of :name

  fields :code, :phone_number, :invitedBy, :location_ids, :is_accepted

  def self.model_base_uri
    load_settings
    @@settings["parse_server"] + "/#{model_name_uri}"
  end

end