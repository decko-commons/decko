# -*- encoding : utf-8 -*-

require "recaptcha"

# This initializer module is mostly here to avoid adding methods/vars to the Object
# namespace
module RecaptchaCard
  @deprecated = {
    site_key: :recaptcha_public_key,
    secret_key: :recaptcha_private_key
  }
  @defaults = {
    site_key: "6LdoqpgUAAAAAEdhJ4heI1h3XLlpXcDf0YubriCG",
    secret_key: "6LdoqpgUAAAAAP4Sz1L5PY6VKrum_RFxq4-awj4BH"
  }

  class << self
    def load_recaptcha_config setting
      full_setting = "recaptcha_#{setting}".to_sym
      Cardio.config.send "#{full_setting}=",
                         recaptcha_setting_value(setting, full_setting)
    end

    def using_defaults?
      Cardio.config.recaptcha_site_key == @defaults[:site_key]
    end

    # card config overrides application.rb config overrides default
    def recaptcha_setting_value setting, full_setting
      card_value(setting) ||                  # card content
        config_value(full_setting) ||         # application.rb (current setting)
        config_value(@deprecated[setting]) || # application.rb (deprecated setting)
        @defaults[setting]
    end

    def config_value setting
      Cardio.config.send setting
    end

    def card_value setting
      # prevent breakage in migrations
      return unless Card::Codename.exist?(:recaptcha_settings) &&
                    Card::Codename.exist?(setting)

      value = :recaptcha_settings.card&.fetch(setting)&.content
      value if value.present?
    end
  end
end

ActiveSupport.on_load :after_card do
  Recaptcha.configure do |config|
    %i[site_key secret_key].each do |setting|
      RecaptchaCard.load_recaptcha_config setting
    end
    config.verify_url = "https://www.google.com/recaptcha/api/siteverify"
  end
end

CardController.include ::Recaptcha::Verify
