# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::NestList do
  check_html_views_for_errors

  specify "#item_names" do
    card = Card.new name: "test", type_id: Card::NestListID,
                    content: "{{A|text}}\n{{+B}}\n{{C|title: t}}"
    expect(card.item_names).to contain_exactly "A", "test+B", "C"
  end

  specify "#item_options" do
    card = Card.new name: "test", type_id: Card::NestListID,
                    content: "{{A|text}}\n{{+B}}\n{{C|title: t|view: x}}"
    expect(card.item_options).to contain_exactly "text", nil, "title: t|view: x"
  end

  specify "edit view" do
    content = "{{A|core}}\n{{+B|title}}\n{{C|type|content}}"
    card = Card.new name: "test", type_id: Card::NestListID, content: content

    expect_view(:edit, card: card).to have_tag("form.card-form") do
      with_hidden_field "card[content]", content
      with_tag "ul._nest-list-ul" do
        with_tag "li.pointer-li", with: { "data-index": "0" } do
          with_tag "input._reference", with: { value: "A" }
          with_tag "input._nest-options", with: { value: "core" }
        end
        with_tag "li.pointer-li", with: { "data-index": "1" } do
          with_tag "input._reference", with: { value: "test+B" }
          with_tag "input._nest-options", with: { value: "title" }
        end
        with_tag "li.pointer-li", with: { "data-index": "2" } do
           with_tag "input._reference", with: { value: "C" }
           with_tag "input._nest-options", with: { value: "type|content" }
        end
      end
    end
  end

  specify "content view" do
    card = Card.new name: "test", type_id: Card::NestListID,
                    content: "{{A|core}}\n{{+B|title}}\n{{C|type|content}}"
    expect_view(:content, card: card).to have_tag("div.content-view") do
      with_text /Alpha.*/
      with_tag "span.card-title", with: { title: "test+B" }
      with_tag "a.cardtype", text: "RichText"
    end
  end
end
