# -*- encoding : utf-8 -*-

describe Card::Set::Type::Set do
  describe :junction_only? do
    it "identifies sets that only apply to plus cards" do
      expect(Card.fetch("*all").junction_only?).to be_falsey
      expect(Card.fetch("*all plus").junction_only?).to be_truthy
      expect(Card.fetch("Book+*type").junction_only?).to be_falsey
      expect(Card.fetch("*to+*right").junction_only?).to be_truthy
      expect(Card.fetch("Book+*to+*type plus right").junction_only?)
        .to be_truthy
    end
  end

  describe :inheritable? do
    it "identifies sets that can inherit rules" do
      expect(Card.fetch("A+*self").inheritable?).to be_falsey
      expect(Card.fetch("A+B+*self").inheritable?).to be_truthy
      expect(Card.fetch("Book+*to+*type plus right").inheritable?).to be_truthy
      expect(Card.fetch("Book+*type").inheritable?).to be_falsey
      expect(Card.fetch("*to+*right").inheritable?).to be_truthy
      expect(Card.fetch("*all plus").inheritable?).to be_truthy
      expect(Card.fetch("*all").inheritable?).to be_falsey
    end
  end

  describe "structure rule content" do
    let :nest_syntax do
      "_left+test_another_card|content|content;structure:test_another_card_structure"
    end

    let :structure_rule do
      Card::Auth.as_bot do
        Card.create! name: "test_card+*right+*structure",
                     type_id: Card::HTMLID,
                     content: "{{#{nest_syntax}}}"
      end
    end

    let :nested_card do
      Card::Auth.as_bot do
        Card.create! name: "test_another_card+*right+*structure",
                     type_id: Card::SearchTypeID,
                     content: ' {"type":"basic","left":"_1"}'
      end
    end

    it "renders nest as a link to template editor of nested card's +*right set" do
      expect(structure_rule.format.render_open)
        .to have_tag("a", class: "slotter", text: nest_syntax,
                          href: "/test_another_card+*right" \
                                "?slot%5Btitle%5D=#{CGI.escape nest_syntax}" \
                                "&view=template_editor")
    end

    it "produces template editor with close link within large brackets" do
      set_card = nested_card.fetch trait: :right
      expect(set_card.format.render(:template_editor)).to have_tag("div.card-slot") do
        with_tag "div.template-editor-left", text: "{{"
        with_tag "div.template-editor-main" do
          with_tag "div.template-closer"
          with_tag "div.card-header"
          with_tag "div.card-body"
        end
        with_tag "div.template-editor-right", text: "}}"
      end
    end
  end
end
