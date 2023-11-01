RSpec.describe Card::Set::Mod::Type do
  include_examples "mod admin config", :mod_list, nil,
                   %i[content_options content_option_view]
end
