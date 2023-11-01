RSpec.describe Card::Set::Mod::Type do
  include_examples "mod admin config", :mod_integrate,  %i[on_create on_update on_delete]
end
