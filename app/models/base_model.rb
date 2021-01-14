class BaseModel < ParseResource::Base
  def self.model_base_uri
    load_settings

    @@settings["parse_server"] + "/#{model_name_uri}"
  end

  def self.load_settings
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

  # Batch requests
  # Sends multiple requests to /batch
  # Set slice_size to send larger batches. Defaults to 20 to prevent timeouts.
  # Parse doesn't support batches of over 20.
  #
  def self.batch_save(save_objects, slice_size = 20, method = nil)
    return true if save_objects.blank?
    load_settings

    base_uri = @@settings['parse_server'] + "/batch"
    app_id = @@settings['app_id']
    master_key = @@settings['master_key']

    res = RestClient::Resource.new(base_uri, app_id, master_key)

    # Batch saves seem to fail if they're too big. We'll slice it up into multiple posts if they are.
    save_objects.each_slice(slice_size) do |objects|
      # attributes_for_saving
      batch_json = {"requests" => []}

      objects.each do |item|
        method ||= (item.new?) ? "POST" : "PUT"
        object_path = "/parse/#{item.class.model_name_uri}"
        object_path = "#{object_path}/#{item.id}" if item.id
        json = {
            "method" => method,
            "path" => object_path
        }
        json["body"] = item.attributes_for_saving unless method == "DELETE"
        batch_json["requests"] << json
      end
      res.post(batch_json.to_json, :content_type => "application/json") do |resp, req, res, &block|
        response = JSON.parse(resp) rescue nil
        if resp.code == 400
          return false
        end
        if response && response.is_a?(Array) && response.length == objects.length
          merge_all_attributes(objects, response) unless method == "DELETE"
        end
      end
    end
    true
  end

  # Creates a RESTful resource for file uploads
  # sends requests to [base_uri]/files
  #
  def self.upload(file_instance, filename, options={})
    load_settings

    base_uri = @@settings['parse_server'] + "/files"

    #refactor to settings['app_id'] etc
    app_id = @@settings['app_id']
    master_key = @@settings['master_key']

    options[:content_type] ||= 'image/jpg' # TODO: Guess mime type here.
    file_instance = File.new(file_instance, 'rb') if file_instance.is_a? String

    filename = filename.parameterize

    private_resource = RestClient::Resource.new "#{base_uri}/#{filename}", app_id, master_key
    private_resource.post(file_instance, options) do |resp, req, res, &block|
      return false if resp.code == 400
      return JSON.parse(resp) rescue {"code" => 0, "error" => "unknown error"}
    end
    false
  end

  # Creates a RESTful resource
  # sends requests to [base_uri]/[classname]
  #
  def self.resource
    load_settings

    #refactor to settings['app_id'] etc
    parse_server = @@settings['parse_server']
    app_id = @@settings['app_id']
    master_key = @@settings['master_key']
    RestClient::Resource.new(parse_server + "/#{model_name_uri}", app_id, master_key)
  end
end