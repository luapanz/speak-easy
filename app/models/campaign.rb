class Campaign < BaseModel
  # validates_presence_of :name

  fields :object_id, :offer_title, :run_date, :location_ids, :agent_ids, :photo_url, :details, :coupon_code,
         :offer_condition, :age, :restrictions, :offer_type_id, :coupons, :add_upcoming, :select_all_agents,
         :business_point, :num_agents, :offer_type_id, :num_coupons, :isOfferCompleted, :offerOff, :upcoming,
         :custom_action, :cta, :cta_text, :redirect_url, :start_date, :activate_date, :run_interval, :pixel_id,
         :limited_coupons, :video_url, :video_thumb_url, :send_owner, :owner_location, :createdAt, :target_audience

  def self.parse_class_name
    'offer'
  end

  def self.model_base_uri
    load_settings
    @@settings["parse_server"] + "/#{model_name_uri}"
  end
end
