default: &default
  secret_key_base: ##SECRET_KEY_BASE##

development:
  <<: *default

test:
  <<: *default

production:
  <<: *default