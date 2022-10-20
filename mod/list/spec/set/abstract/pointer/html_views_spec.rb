# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Abstract::Pointer do
  context "with simple Pointer" do
    def card_subject
      pointer = Card["Sample Pointer"]
      pointer << "A"
      pointer
    end

    check_views_for_errors
  end

  describe "editors" do
    let(:item_name) { "nonexistingcardmustnotexistthisistherule" }

    let(:pointer) do
      Card::Auth.as_bot do
        Card.create name: "tp", type: "pointer", content: "[[#{item_name}]]"
      end
    end

    it "includes nonexisting card in radio options" do
      common_with = { type: "radio",
                      value: "nonexistingcardmustnotexistthisistherule",
                      id: "pointer-radio-nonexistingcardmustnotexistthisistherule",
                      checked: "checked" }
      expect(pointer.format.render_radio)
        .to have_tag "input.pointer-radio-button",
                     with: common_with.merge(name: "pointer_radio_button-tp")
    end

    it "includes nonexisting card in checkbox options" do
      expect(pointer.format.render_checkbox)
        .to have_tag "input.pointer-checkbox-button",
                     with: {
                       type: "checkbox",
                       value: "nonexistingcardmustnotexistthisistherule",
                       id: "pointer-checkbox-nonexistingcardmustnotexistthisistherule",
                       checked: "checked"
                     }
    end

    it "includes nonexisting card in select options" do
      option_html = "option[value='#{item_name}'][selected='selected']"
      assert_view_select pointer.format.render_select, option_html, item_name
    end

    it "includes nonexisting card in multiselect options" do
      option_html = "option[value='#{item_name}'][selected='selected']"
      assert_view_select pointer.format.render_multiselect, option_html,
                         item_name
    end
  end

  describe "list_input" do
    subject do
      pointer = Card.new name: "tp", type: "pointer", content: pointer_content
      pointer.format._render :input
    end

    let(:pointer_content) { "[[Jane]]\n[[John]]" }

    it "contains hidden content input" do
      is_expected.to have_tag("input#card_content",
                              with: { name: "card[content]",
                                      value: pointer_content })
    end

    it "contains first item in input tag" do
      is_expected.to have_tag("li.pointer-li") do
        with_tag :input, with: { name: "pointer_item", value: "Jane" }
      end
    end

    it "contains second item in input tag" do
      is_expected.to have_tag("li.pointer-li") do
        with_tag :input, with: { name: "pointer_item", value: "John" }
      end
    end

    it "contains 'add another' button" do
      is_expected.to have_tag(:button, with: { type: :submit }, text: /add another/)
    end
  end
end
