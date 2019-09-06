# -*- encoding : utf-8 -*-

describe Card::Set::Type::Date do
  it "has special editor" do
    assert_view_select render_input("Date"), 'input[class~="date-editor"]'
  end
end
