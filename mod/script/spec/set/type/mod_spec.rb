RSpec.describe Card::Set::Mod::Type do
  include_examples "mod admin config",
                   :mod_script, %i[script],
                   nil,
                   %i[java_script coffee_script local_script_folder_group local_script_manifest_group]
end
