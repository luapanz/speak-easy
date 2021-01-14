default: &default
  app_id: ##PARSE_APP_ID##
  master_key: ##PARSE_MASTER_KEY##
  parse_server: ##PARSE_SERVER_URL##

development:
  <<: *default

test:
  <<: *default

production:
  <<: *default