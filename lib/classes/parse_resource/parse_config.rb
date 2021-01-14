# encoding: utf-8
module ParseResource
  # Parse Application
  # https://parse.com/docs/rest/guide/#config
  class ParseConfig < BaseModel
    def self.config(client = nil)
      load_settings
      base_uri = @@settings['parse_server']  + '/config'
      app_id = @@settings['app_id']
      master_key = @@settings['master_key']
      resource = RestClient::Resource.new(base_uri, app_id, master_key)

      c = resource.get
      JSON.parse c
    end
  end
end