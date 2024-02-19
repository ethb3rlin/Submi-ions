Rails.application.config.middleware.use OmniAuth::Builder do
  provider :ethereum, custom_title: "EthBerlin Submißions portal"
end
