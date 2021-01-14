class User < ParseUser

  def save
    if valid?
      if new?
        create
      else
        update
      end
    else
      false
    end
  end

  def self.check_password(username, password)
    load_settings
    base_uri   = @@settings['parse_server'] + "/login"
    app_id     = @@settings['app_id']
    master_key = @@settings['master_key']
    resource = RestClient::Resource.new(base_uri, app_id, master_key)

    begin
      resource.get(:params => {:username => username, :password => password})
      true
    rescue
      false
    end
  end


  def self.model_base_uri
    load_settings
    @@settings["parse_server"] + "/#{model_name_uri}"
  end

  attr_accessor :invite_code
  attr_accessor :password_repeat
  attr_accessor :role
  attr_accessor :business_name
  attr_accessor :locations
  attr_accessor :location_id
  attr_accessor :access_code

  before_validation :downcase_fields

  fields :firstname, :lastname, :phone, :photo_url, :is_active, :business_id,
         :username,  :role, :country, :tos_version, :send_invitation,
         :send_password, :createdBy, :overall_rscore, :tos_acceptance_date, :locations,
         :location_id, :emailVerified, :wc_customer_id, :csv_import, :stripe_id, :send_notifications,
         :beta_tester, :createdAt, :pn, :show_dialog, :subscription_status, :coupon
  fields :email

  protected

  def downcase_fields
    self.username.downcase!
    self.email.downcase!
  end

  def self.authenticate(username, password)
    load_settings
    base_uri   = @@settings['parse_server'] + "/login"
    app_id     = @@settings['app_id']
    master_key = @@settings['master_key']
    resource = RestClient::Resource.new(base_uri, app_id, master_key)

    begin
      resp = resource.get(:params => {:username => username, :password => password})
      user = model_name.to_s.constantize.new(JSON.parse(resp), false)

      user
    rescue
      false
    end

  end

  def self.authenticate_with_facebook(user_id, access_token, expires)
    load_settings
    base_uri   = @@settings['parse_server'] + "/users"
    app_id     = @@settings['app_id']
    master_key = @@settings['master_key']
    resource = RestClient::Resource.new(base_uri, app_id, master_key)

    begin
      resp = resource.post(
          { "authData" =>
                { "facebook" =>
                      {
                          "id" => user_id,
                          "access_token" => access_token,
                          "expiration_date" => Time.now + expires.to_i
                      }
                }
          }.to_json,
          :content_type => 'application/json', :accept => :json)
      user = model_name.to_s.constantize.new(JSON.parse(resp), false)
      user
    rescue
      false
    end
  end

  def self.reset_password(email)
    load_settings
    base_uri   = @@settings['parse_server'] + "/requestPasswordReset"
    app_id     = @@settings['app_id']
    master_key = @@settings['master_key']
    resource = RestClient::Resource.new(base_uri, app_id, master_key)

    begin
      resp = resource.post({:email => email}.to_json, :content_type => 'application/json')
      true
    end
  end

  def self.logout(user)
    load_settings
    base_uri   = @@settings['parse_server'] + "/logout"
    app_id     = @@settings['app_id']
    master_key = @@settings['master_key']
    resource = RestClient::Resource.new(base_uri, app_id, master_key)

    begin
      resp = resource.post({:email => email}.to_json, :content_type => 'application/json')
      true
    end
  end


end
