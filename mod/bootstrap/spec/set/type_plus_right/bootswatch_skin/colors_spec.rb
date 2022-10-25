RSpec.describe Card::Set::TypePlusRight::BootswatchSkin::Colors do
  check_views_for_errors views: views(:html).unshift(:bar_right)

  def card_subject
    "customized yeti skin".card.colors_card
  end

  example "#colors fetches color definitions" do
    expect(card_subject.colors).to include(yellow: "#ffc107")
  end

  example "#theme_colors fetches variable definitions" do
    # card-cap-bg is temporarily removed from the variables list
    expect(card_subject.theme_colors)
      .to include(warning: "$yellow")
  end

  specify "view bar_middle" do
    expect_view(:bar_middle).to have_tag("div.colorpicker-element") do
      with_tag "div.input-group-addon"
      with_tag "span"
      with_tag "i"
    end
  end

  describe "event: translate_variables_to_scss" do
    it "supports colors param" do
      Card::Env.with_params colors: { yellow: "#FFCC00" } do
        card_subject.update!({})
      end
      expect(card_subject.colors).to include(yellow: "#FFCC00")
    end
  end
end
