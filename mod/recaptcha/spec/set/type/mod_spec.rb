RSpec.describe Card::Set::Mod::Type do
  include_examples "mod admin config", :mod_recaptcha,
                   %i[captcha],
                   { "basic" => ["recaptcha_settings"] },
                   nil
end