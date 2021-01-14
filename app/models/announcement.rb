class Announcement < BaseModel
  
    fields :object_id, :photo_url, :details, :location_ids, :createdBy_point, :business_point, :end_date, :title,
           :viewed, :liked, :disliked, :description, :run_time_frame, :locations
  
    def self.parse_class_name
      'announcement'
    end
  
    def self.model_base_uri
      load_settings
      @@settings["parse_server"] + "/#{model_name_uri}"
    end
end
  