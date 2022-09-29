# -*- encoding : utf-8 -*-

class UpgradeRecaptchaToV3 < Cardio::Migration::Core
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
                   name: "#{Card[:recaptcha_settings].name}+#{new_name} key",
                   codename: "recaptcha_#{new_name}_key"
    end

    Card.ensure name: [Card[:recaptcha_settings].name, "minimum score"],
                codename: "recaptcha_minimum_score",
                type_id: Card::NumberID
  end
end
