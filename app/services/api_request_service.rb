class ApiRequestService
  def call_cloud_function(function_name, data)
    config = get_config
    base_uri = config['parse_server'] + '/functions/' + function_name
    app_id = config['app_id']

    uri = URI(base_uri)
    req = Net::HTTP::Post.new(
        uri.path,
        'Content-Type' => 'application/json'
    )
    req.add_field('X-Parse-Application-Id', app_id)

    req.body = data.to_json

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    http.request(req)
  end

  def get_config
    @@settings ||= begin
      path = "config/parse_resource.yml"
      environment = defined?(Rails) && Rails.respond_to?(:env) ? Rails.env : ENV["RACK_ENV"]
      if FileTest.exist? (path)
        YAML.load(ERB.new(File.new(path).read).result)[environment]
      elsif ENV["PARSE_RESOURCE_APPLICATION_ID"] && ENV["PARSE_RESOURCE_MASTER_KEY"]
        settings = HashWithIndifferentAccess.new
        settings['app_id'] = ENV["PARSE_RESOURCE_APPLICATION_ID"]
        settings['master_key'] = ENV["PARSE_RESOURCE_MASTER_KEY"]
        settings
      else
        raise "Cannot load parse_resource.yml and API keys are not set in environment"
      end
    end
    @@settings
  end
end