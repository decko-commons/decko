RSpec.describe Card::Set::Type::Mod do
  include_examples "mod admin config", :mod_follow,
                   %i[follow_fields follow],
                   nil,
                   [["Template", %i[notification_template]]]
end
