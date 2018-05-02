RSpec.describe Card::Set::TypePlusRight::CustomizedBootswatchSkin::Colors do
  let(:card) do
    Card::Env.params[:theme] = "journal"
    Card::Auth.as_bot do
      create_customized_bootswatch_skin "my skin"
    end
  end

  it "fetches variable value from variable card" do
    expect(card.colors_card.colors).to include(white: "#fff")
  end

  it "fetches missing variable value from bootstrap source" do
    pending "card-cap-bg is temporarily removed from the variables list"
    expect(card.colors_card.theme_colors)
      .to include("card-cap-bg": "rgba($black, .03)")
  end
end
