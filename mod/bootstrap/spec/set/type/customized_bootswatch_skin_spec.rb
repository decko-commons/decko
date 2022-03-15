RSpec.describe Card::Set::Type::CustomizedBootswatchSkin do
  let(:card) do
    Card::Env.params[:theme] = "journal"
    Card::Auth.as_bot do
      create_customized_bootswatch_skin "my skin"
    end
  end

  specify ".read_bootstrap_variables" do
    expect(card.read_bootstrap_variables).to include "$primary"
  end

  it "copies content from source file" do
    expect(card.variables).to include("$cyan:    #369 !default;")
  end

  it "includes color definitions", as_bot: true do
    card
    ensure_card ["my skin", :colors], content: "$primary: $cyan !default"
    expect(card.content).to include "$primary: $cyan !default"
  end

  example "update old skin", as_bot: true do
    create_skin "old skin", content: ["bootstrap default skin", "custom css"]
    Card["old skin"].update! type_id: Card::CustomizedBootswatchSkinID

    expect_card("old skin")
      .to have_a_field(:stylesheets).pointing_to "custom css"
  end
end
