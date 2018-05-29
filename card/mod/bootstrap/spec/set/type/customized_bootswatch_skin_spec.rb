RSpec.describe Card::Set::Type::CustomizedBootswatchSkin do
  let(:card) do
    Card::Env.params[:theme] = "journal"
    Card::Auth.as_bot do
      create_customized_bootswatch_skin "my skin"
    end
  end

  specify ".read_bootstrap_variables" do
    expect(described_class.read_bootstrap_variables).to include "$primary"
  end

  it "copies content from source file" do
    expect(card.variables).to include("$cyan:    #369 !default;")
  end

  it "includes color definitions", as_bot: true do
    card
    ensure_card ["my skin", :colors], content: "$primary: $cyan !default"
    expect(card.content).to include "$primary: $cyan !default"
  end
end
