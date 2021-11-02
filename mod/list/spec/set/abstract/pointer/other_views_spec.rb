# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Abstract::Pointer do
  before do
    Card::Env.params[:max_export_depth] = 4
  end

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
        { format: :css }
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

    def expect_hash_list export, *hash_list
      expect(export).to include(*hash_list.map { |i| a_hash_including i })
    end

    context "with pointer card" do
      it "contains cards in the pointer card and its children" do
        Card::Env.params[:max_export_depth] = 3

        expect_hash_list(
          json_export(type: :pointer, content: [elbert.name, elbert_punchline.name]),
          { name: "normal pointer",
            type: "Pointer",
            content: "Elbert Hubbard\nElbert Hubbard+punchline" },
          { name: "Elbert Hubbard",
            type: "RichText",
            content: "Do not take life too seriously." },
          { name: "Elbert Hubbard+punchline",
            type: "RichText",
            content: "You will never get out of it alive." }
        )
      end

      it "handles multi level pointer cards" do
        expect_hash_list(
          json_export(content: [elbert_container.name, elbert_punchline.name]),
          { name: "normal pointer",
            type: "Pointer",
            content: "elbert container\nElbert Hubbard+punchline" },
          { name: "elbert container",
            type: "Pointer",
            content: "Elbert Hubbard" },
          { name: "Elbert Hubbard",
            type: "RichText",
            content: "Do not take life too seriously." },
          { name: "Elbert Hubbard+punchline",
            type: "RichText",
            content: "You will never get out of it alive." }
        )
      end

      it "stops if the depth count > 10" do
        expect_hash_list(
          json_export(name: "normal pointer", content: "normal pointer"),
          name: "normal pointer", type: "Pointer", content: "normal pointer"
        )
      end
    end

    context "with Skin card" do
      it "contains cards in the pointer card and its children" do
        expect_hash_list(
          json_export(type: :skin, content: [elbert.name]),
          { name: "normal pointer",
            type: "Skin",
            content: "Elbert Hubbard" },
          { name: "Elbert Hubbard",
            type: "RichText",
            content: "Do not take life too seriously." }
        )
      end
    end

    context "with search card" do
      it "contains cards from search card and its children" do
        elbert
        elbert_punchline
        elbert_quote

        expect_hash_list(
          json_export(name: "search card",
                      type: :search_type,
                      content: %({"left":"Elbert Hubbard"})),
          { name: "search card",
            type: "Search",
            content: %({"left":"Elbert Hubbard"}) },
          { name: "Elbert Hubbard+punchline",
            type: "RichText",
            content: "You will never get out of it alive." },
          { name: "Elbert Hubbard+quote",
            type: "RichText",
            content: "Procrastination is the art of keeping up with yesterday." }
        )
      end
    end
  end
end
