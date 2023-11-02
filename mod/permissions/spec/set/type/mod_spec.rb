RSpec.describe Card::Set::Type::Mod do
  include_examples "mod admin config", :mod_permissions, %i[create read update delete]
end
