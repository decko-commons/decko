RSpec.describe Card::Set::Mod::Type do
  include_examples "mod admin config", :mod_style, %i[style], nil,
                   [["Assets", %i[local_style_folder_group local_style_manifest_group]],
                    ["Styling", %i[css scss skin]]]
end
end