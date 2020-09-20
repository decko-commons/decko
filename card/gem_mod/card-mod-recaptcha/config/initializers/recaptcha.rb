# -*- encoding : utf-8 -*-
require "recaptcha"

# This initializer module is mostly here to avoid adding methods/vars to the Object
# namespace
module RecaptchaCard
  @deprecated = {
    recaptcha_site_key: :recaptcha_public_key,
    recaptcha_secret_key: :recaptcha_private_key
  }
  @defaults = {
    recaptcha_site_key: "6LdoqpgUAAAAAEdhJ4heI1h3XLlpXcDf0YubriCG",
    recaptcha_secret_key: "6LdoqpgUAAAAAP4Sz1L5PY6VKrum_RFxq4-awj4BH"
  }

  mattr_accessor :using_card_defaults

  class << self
    def load_recaptcha_config setting
      setting = "recaptcha_#{setting}".to_sym
      Cardio.config.send "#{setting}=", recaptcha_setting_value(setting)
    end

    def using_defaults?
      Cardio.config.recaptcha_site_key == @defaults[:recaptcha_site_key]
    end

    # card config overrides application.rb config overrides default
    def recaptcha_setting_value setting
      card_value(setting) ||                  # card content
        config_value(setting) ||              # application.rb (current setting)
        config_value(@deprecated[setting]) || # application.rb (deprecated setting)
        @defaults[setting]
    end

    def config_value setting
      Cardio.config.send setting
    end

    def card_value setting
      return unless Card::Codename.exist? setting # prevents breakage in migrations
      value = Card[setting]&.content
      value if value.present?
    end
  end
end

ActiveSupport.on_load :after_card do
  Recaptcha.configure do |config|
    %i[site_key secret_key].each do |setting|
      config.send "#{setting}=", RecaptchaCard.load_recaptcha_config(setting)
    end
    config.verify_url = "https://www.google.com/recaptcha/api/siteverify"
  end
end
