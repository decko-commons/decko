Cardio::Railtie.config.tap do |config|
  config.account_password_length = 8
  config.account_password_requirements = %i[lower upper special_char number]
end
