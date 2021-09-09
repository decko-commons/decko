# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::Cardtype do
  describe "view: add_button" do
    it "creates link with correct path" do
      expect(render_content("{{RichText|add_button}}"))
        .to have_tag('a[href="/type/RichText?view=new_in_modal"]', text: "Add RichText")
    end

    it "handles title argument" do
      expect(render_content("{{RichText|add_button;title: custom link text}}"))
        .to have_tag('a[href="/type/RichText?view=new_in_modal"]',
                     text: "custom link text")
    end

    it "handles params" do
      expect(render_content("{{RichText|add_button;params:_dataset=_self}}"))
        .to have_tag('a[href="/type/RichText?_dataset=Tempo+Rary+2&view=new_in_modal"]')
    end
  end
end
