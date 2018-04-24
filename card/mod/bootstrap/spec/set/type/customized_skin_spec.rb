RSpec.describe Card::Set::Type::CustomizedSkin do
  specify ".read_bootstrap_variables" do
    expect(described_class.read_bootstrap_variables).to include "$primary"
  end

  let(:card) do
    Card::Env.params[:theme] = "journal"
    Card::Auth.as_bot do
      create_customized_skin "my skin"
    end
  end

  it "copies content from source file" do
    expect(card.variables).to include("$cyan:    #369 !default;")
  end
end
