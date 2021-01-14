---
default: &default
  cloud_name: ##CLOUDINARY_CLOUD_NAME##
  api_key: ##CLOUDINARY_API_KEY##
  api_secret: ##CLOUDINARY_API_SECRET##
  enhance_image_tag: ##CLOUDINARY_ENHANCE_IMAGE_TAG##
  static_image_support: ##CLOUDINARY_STATIC_IMAGE_SUPPORT##
  folder: ##CLOUDINARY_FOLDER##

development:
  <<: *default

test:
  <<: *default

production:
  <<: *default