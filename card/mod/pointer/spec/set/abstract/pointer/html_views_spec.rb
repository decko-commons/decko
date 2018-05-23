# -*- encoding : utf-8 -*-

describe Card::Set::Abstract::Pointer do
  extend Card::SpecHelper::ViewHelper::ViewDescriber

  context "with simple Pointer" do
    let(:pointer) do
      pointer = Card["Sample Pointer"]
      pointer << "A"
      pointer
    end

    describe_views :core, :closed_content, :editor,
                   :list, :autocomplete, :checkbox,
                   :radio, :select, :multiselect do
      it "doesn't have errors" do
        expect(pointer.format.render(view)).to lack_errors
      end
    end
  end

  describe "editors" do
    let(:item_name) { "nonexistingcardmustnotexistthisistherule" }

    let(:pointer) do
      Card::Auth.as_bot do
        Card.create name: "tp", type: "pointer", content: "[[#{item_name}]]"
      end
    end

    let(:new_type) do
      Card::Auth.as_bot do
        mylist = Card.create! name: "MyList", type_id: Card::CardtypeID
        Card.create name: "MyList+*type+*default", type_id: Card::PointerID
        mylist
      end
    end

    let(:inherit_pointer) do
      Card::Auth.as_bot do
        Card.create name: "ip", type_id: new_type.id, content: "[[#{item_name}]]"
      end
    end

    it "includes nonexisting card in radio options" do
      common_html = 'input[class="pointer-radio-button"]' \
                    '[checked="checked"]' \
                    '[type="radio"]' \
                    '[value="nonexistingcardmustnotexistthisistherule"]' \
                    '[id="pointer-radio-nonexistingcardmustnotexistthisistherule"]'
      option_html = common_html + '[name="pointer_radio_button-tp"]'
      assert_view_select pointer.format.render_radio, option_html
      option_html = common_html + '[name="pointer_radio_button-ip"]'
      assert_view_select inherit_pointer.format.render_radio, option_html
    end

    it "includes nonexisting card in checkbox options" do
      option_html = 'input[class="pointer-checkbox-button"]' \
                    '[checked="checked"]' \
                    '[type="checkbox"]' \
                    '[value="nonexistingcardmustnotexistthisistherule"]' \
                    '[id="pointer-checkbox-nonexistingcardmustnotexistthisistherule"]'
      # debug_assert_view_select @pointer.format.render_checkbox, option_html
      assert_view_select inherit_pointer.format.render_checkbox, option_html
    end

    it "includes nonexisting card in select options" do
      option_html = "option[value='#{item_name}'][selected='selected']"
      assert_view_select pointer.format.render_select, option_html, item_name
      assert_view_select inherit_pointer.format.render_select, option_html,
                         item_name
    end

    it "includes nonexisting card in multiselect options" do
      option_html = "option[value='#{item_name}'][selected='selected']"
      assert_view_select pointer.format.render_multiselect, option_html,
                         item_name
      assert_view_select inherit_pointer.format.render_multiselect,
                         option_html, item_name
    end
  end

  describe "list_input" do
    subject do
      pointer = Card.new name: "tp", type: "pointer", content: pointer_content
      pointer.format._render :editor
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
