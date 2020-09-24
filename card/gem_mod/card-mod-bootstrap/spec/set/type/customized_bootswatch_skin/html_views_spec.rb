RSpec.describe Card::Set::Type::CustomizedBootswatchSkin::HtmlViews do
  specify "view core" do
    expect_view(:core).to have_tag("h5")
  end
end
