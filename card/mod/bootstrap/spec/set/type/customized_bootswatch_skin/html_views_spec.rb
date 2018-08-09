RSpec.describe Card::Set::Type::CustomizedBootswatchSkin::HtmlViews do
  specify "view core" do
    expect_view(:core).to have_tag("div.card-slot.missing-view")
  end
end
