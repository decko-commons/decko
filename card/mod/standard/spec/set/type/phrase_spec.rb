# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::Phrase do
  it "has special editor" do
    assert_view_select render_input("Phrase"),
                       'input[type="text"][class~="d0-card-content"]'
  end
end
