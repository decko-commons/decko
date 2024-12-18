# -*- encoding : utf-8 -*-

require "recaptcha"

# This Recaptcha initializer handles the multiple ways in which the recaptcha site and
# secret key can be configured.  These include:
#
# - in config files with config.recaptcha_site_key and config.recaptcha_secret_key
#   (PREFERRED!)
# - via the :recaptcha_settings card
# - in config files with config.recaptcha_public_key and config.recaptcha_private_key
#   (DEPRECATED!)
# - by using the defaults below (DEVELOPMENT ONLY)
#
module RecaptchaCard
  @deprecated = {
    site_key: :recaptcha_public_key,
    secret_key: :recaptcha_private_key
  }
  @defaults = {
    site_key: "6Lc3c-EoAAAAALnzfnHIWb5Rqy-rNui8l8qsguYG",
    secret_key: "6Lc3c-EoAAAAAEg9K_IAUNgx73eTbtBucCGnOQqf"
  }

  class << self
    def load_recaptcha_config setting
      full_setting = :"recaptcha_#{setting}"
      Cardio.config.send "#{full_setting}=",
                         recaptcha_setting_value(setting, full_setting)
    end

    def using_defaults?
      Cardio.config.recaptcha_site_key == @defaults[:site_key]
    end

    private

    # card config overrides application.rb config overrides default
    def recaptcha_setting_value setting, full_setting
      card_value(full_setting) ||             # card content
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

      value = setting.card&.content
      value if value.present?
    end
  end
end

ActiveSupport.on_load :after_card do
  Recaptcha.configure do |config|
    %i[site_key secret_key].each do |setting|
      config.send "#{setting}=", RecaptchaCard.load_recaptcha_config(setting)
    end
    config.verify_url = Cardio.config.recaptcha_verify_url
  end
end

CardController.include Recaptcha::Verify
