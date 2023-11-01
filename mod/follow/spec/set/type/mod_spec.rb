RSpec.describe Card::Set::Mod::Type do
  include_examples "mod admin config", :mod_layout,
                   %i[layout head], nil, %i[notification_template]
end
