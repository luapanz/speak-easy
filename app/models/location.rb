class Location < BaseModel
  # validates_presence_of :name

  fields :name, :logo_url, :phone, :street, :city, :state, :zip,
    :is_active, :suite, :country, :url, :is_virtual, :createdBy, :business_id

  def self.parse_class_name
    'location'
  end


  def self.model_base_uri
    load_settings

    @@settings["parse_server"] + "/#{model_name_uri}"
  end

  def address
    ([self.street,self.city,self.state,self.zip] - ["", nil]).join(', ')
  end

  def full_address
    self.address + ', ' + self.country
  end

  def http_url
    url = (self.url || "").strip
    if url !~ /^http/i
      url = 'http://' + url;
    end
    url
  end

  def initialize(attributes={}, new=true)
    if attributes['is_virtual']
      attributes['street'] = nil
      attributes['city'] = nil
      attributes['suite'] = nil
      attributes['state'] = nil
      attributes['zip'] = nil
    end
    super(attributes, new)
  end

  def update_attributes(attributes={})
    if attributes['is_virtual']
      attributes['street'] = nil
      attributes['city'] = nil
      attributes['suite'] = nil
      attributes['state'] = nil
      attributes['zip'] = nil
    end
    super(attributes)
  end


  # def to_param
  #   objectId
  # end
end