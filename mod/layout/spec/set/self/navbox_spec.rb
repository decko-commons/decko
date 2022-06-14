# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Self::Navbox do
  it "has a form" do
    expect_view(:core).to have_tag "form.search-box-form" do
      with_tag "select.search-box"
    end
  end

  it "has no errors" do
    expect_view(:core).to lack_errors
  end
end
