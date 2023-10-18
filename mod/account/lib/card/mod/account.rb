Cardio::Railtie.config.tap do |config|
    config.account_password_length = 8
    config.account_password_chars = [:lower, :upper, :symbol, :number]
end
