# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Abstract::Pointer do
  describe "json" do
    include_context "json context"

    def card_subject
      sample_pointer
    end

    let(:item_names) { %w[r1 r2 r3] }

    specify "view: links" do
      expect_view(:links, format: :json).to eq([])
    end

    specify "view: items" do
      expect_view(:items, format: :json)
        .to contain_exactly(*item_names.map { |i| structured_atom_values Card[i] })
    end
  end

  describe "css" do
    let(:css) { "#box { display: block }" }

    before do
      Card.create name: "my css", content: css
    end

    it "renders CSS of items" do
      css_list = render_card(
        :content,
        { type: Card::PointerID, name: "my style list", content: "[[my css]]" },
        format: :css
      )
      #      css_list.should =~ /STYLE GROUP\: \"my style list\"/
      #      css_list.should =~ /Style Card\: \"my css\"/
      expect(css_list).to match(/#{Regexp.escape css}/)
    end
  end

  describe "rendering json in export mode" do
    let(:elbert) do
      create "Elbert Hubbard", content: "Do not take life too seriously."
    end
    let(:elbert_punchline) do
      create "Elbert Hubbard+punchline", content: "You will never get out of it alive."
    end
    let(:elbert_quote) do
      create "Elbert Hubbard+quote",
             content: "Procrastination is the art of keeping up with yesterday."
    end
    let(:elbert_container) do
      create "elbert container", type_id: Card::PointerID, content: "[[#{elbert.name}]]"
    end

    def json_export args={}
      @json ||= begin
                  args[:name] ||= "normal pointer"
                  args[:type] ||= :pointer
                  if args[:content].is_a?(Array)
                    args[:content] = args[:content].to_pointer_content
                  end
                  Card::Auth.as_bot do
                    collection_card = Card.create! args
                    card = Card.create! name: "export card",
                                        type_id: Card::PointerID,
                                        content: "[[#{collection_card.name}]]"
                    card.format(:json).render_export
                  end
                end
    end

    context "pointer card" do
      it "contains cards in the pointer card and its children" do
        Card::Env.params[:max_export_depth] = 3
        json_export type: :pointer, content: [elbert.name, elbert_punchline.name]

        expect(json_export)
          .to include(
            a_hash_including(name: "normal pointer",
                             type: "Pointer",
                             content: "[[Elbert Hubbard]]\n[[Elbert Hubbard+punchline]]"),
            a_hash_including(name: "Elbert Hubbard",
                             type: "RichText",
                             content: "Do not take life too seriously."),
            a_hash_including(name: "Elbert Hubbard+punchline",
                             type: "RichText",
                             content: "You will never get out of it alive.")
          )
      end

      it "handles multi level pointer cards" do
        Card::Env.params[:max_export_depth] = 4
        json_export type: :pointer,
                    content: [elbert_container.name, elbert_punchline.name]

        expect(json_export)
          .to include(
            a_hash_including(name: "normal pointer",
                             type: "Pointer",
                             content: "[[elbert container]]\n" \
                                  "[[Elbert Hubbard+punchline]]"),
            a_hash_including(name: "elbert container",
                             type: "Pointer",
                             content: "[[Elbert Hubbard]]"),
            a_hash_including(name: "Elbert Hubbard",
                             type: "RichText",
                             content: "Do not take life too seriously."),
            a_hash_including(name: "Elbert Hubbard+punchline",
                             type: "RichText",
                             content: "You will never get out of it alive.")
          )
      end

      it "stops if the depth count > 10" do
        json_export type: :pointer, name: "normal pointer", content: ["normal pointer"]
        expect(json_export)
          .to include(a_hash_including(name: "normal pointer", type: "Pointer",
                                       content: "[[normal pointer]]"))
      end
    end

    context "Skin card" do
      it "contains cards in the pointer card and its children" do
        Card::Env.params[:max_export_depth] = 4
        expect(json_export(type: :skin, content: [elbert.name]))
          .to include(
            a_hash_including(name: "normal pointer",
                             type: "Skin",
                             content: "[[Elbert Hubbard]]"),
            a_hash_including(name: "Elbert Hubbard",
                             type: "RichText",
                             content: "Do not take life too seriously.")
          )
      end
    end

    context "search card" do
      it "contains cards from search card and its children" do
        elbert
        elbert_punchline
        elbert_quote

        Card::Env.params[:max_export_depth] = 4
        json_export(name: "search card", type: :search_type,
                    content: %({"left":"Elbert Hubbard"}))
        expect(json_export)
          .to include(
            a_hash_including(name: "search card",
                             type: "Search",
                             content: %({"left":"Elbert Hubbard"})),
            a_hash_including(name: "Elbert Hubbard+punchline",
                             type: "RichText",
                             content: "You will never get out of it alive."),
            a_hash_including(name: "Elbert Hubbard+quote",
                             type: "RichText",
                             content: "Procrastination is " \
                                  "the art of keeping up with yesterday.")
          )
      end
    end
  end
end
