RSpec.describe Card::Set::Type::CustomizedSkin do
  specify ".read_bootstrap_variables" do
    expect(described_class.read_bootstrap_variables).to include "$primary"
  end
end
