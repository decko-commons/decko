RSpec.describe Card::Set::Type::Mod do
  include_examples "mod admin config",
                   :mod_script, %i[script],
                   nil,
                   [["Scripting", %i[java_script coffee_script]],
                    ["Assets", %i[local_script_folder_group local_script_manifest_group]]]
end
