Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, Rails.application.secrets.oauth_client_id,
                           Rails.application.secrets.oauth_client_secret,
                           image_size: 150
end
