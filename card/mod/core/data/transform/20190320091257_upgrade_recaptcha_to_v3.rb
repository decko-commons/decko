# -*- encoding : utf-8 -*-

class UpgradeRecaptchaToV3 < Cardio::Migration::Transform
  def up
    update_card! %i[recaptcha_settings self structure],
                 content: <<~STRING
                   {{+site key}}
                   {{+secret key}}
                   {{+minimum score}}
                   {{+proxy}}
                 STRING

    { public: :site, private: :secret }.each do |old_name, new_name|
      codename = "recaptcha_#{old_name}_key".to_sym
      next unless Card::Codename[codename]

      update_card! codename,
                   name: [:recaptcha_settings, "#{new_name} key"].cardname,
                   codename: "recaptcha_#{new_name}_key"
    end

    Card.ensure name: [:recaptcha_settings, "minimum score"].cardname,
                codename: "recaptcha_minimum_score",
                type: :number
  end
end
