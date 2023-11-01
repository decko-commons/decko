RSpec.describe Card::Set::Type::Mod do
  include_examples "mod admin config", :mod_recaptcha,
                   %i[captcha],
                   { "basic" => ["recaptcha_settings"] },
                   nil
end
