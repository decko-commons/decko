RSpec.describe Card::Set::Type::Mod do
  include_examples "mod admin config", :mod_integrate,  %i[on_create on_update on_delete]
end
