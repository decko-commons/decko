RSpec.describe Card::Set::Type::Mod do
  include_examples "mod admin config", :mod_list,
                   %i[content_options content_option_view],
                   nil,
                   [["Organize", %i[list pointer nest_list link_list]]]
end
