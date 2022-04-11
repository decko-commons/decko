RSpec.describe Card::Set::TypePlusRight::BootswatchSkin::Colors do
  let(:card) do
    Card::Auth.as_bot do
      create_bootswatch_skin "my skin", subfields: { parent: :journal_skin.cardname }
    end
  end

  it "fetches variable value from variable card" do
    expect(card.colors_card.colors).to include(white: "#fff")
  end

  xit "fetches missing variable value from bootstrap source" do
    # card-cap-bg is temporarily removed from the variables list
    expect(card.colors_card.theme_colors)
      .to include("card-cap-bg": "rgba($black, .03)")
  end

  specify "view bar_middle" do
    expect_view(:bar_middle).to have_tag("div.colorpicker-element") do
      with_tag "div.input-group-addon"
      with_tag "span"
      with_tag "i"
    end
  end
end
