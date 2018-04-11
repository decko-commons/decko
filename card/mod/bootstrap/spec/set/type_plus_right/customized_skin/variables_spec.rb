RSpec.describe Card::Set::TypePlusRight::CustomizedSkin::Variables do
  let(:card) do
    Card::Env.params[:theme] = "journal"
    Card::Auth.as_bot do
      create_customized_skin "my skin"
    end
  end

  it "copies content from source file" do
    expect(card.variables).to include("$cyan:    #369 !default;")
  end

  it "fetches variable value from content" do
    expect(card.variables_card.colors).to include(white: "#fff")
  end

  it "fetches missing variable value from bootstrap source" do
    pending "card-cap-bg is temporarily removed from the variables list"
    expect(card.variables_card.theme_colors).to include("card-cap-bg": "rgba($black, .03)")
  end
end
