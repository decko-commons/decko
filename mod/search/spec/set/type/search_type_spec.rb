# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::SearchType do
  let :asearch do
    Card.fetch "User+*type+by_name"
  end

  %w[name bar open titled].each do |view|
    it "handles wrapping item in #{view} view" do
      content = render_content "{{#{asearch.name}|core|#{view}}}"
      expect(content.scan("search-result-item item-#{view}").size).to eq(14)
    end
  end

  it "fails for invalid search syntax" do
    expect { create_search_type "Bad Search", content: "not no search" }
      .to raise_error(/Invalid json unexpected token at 'not no search'/)
  end

  it "handles returning 'count'" do
    rendered = render_card :core, type: "Search",
                                  content: %({ "type":"User", "return":"count"})
    expect(rendered).to eq("14")
  end

  it "passes item args correctly" do
    create_pointer "Pointer2Searches",
                   content: "[[Layout+*type+by name]]\n[[PlainText+*type+by name]]"
    r = render_content "{{Pointer2Searches|core|closed|hide:menu}}"
    expect(r.scan('"view":"link"').size).to eq(0)
    expect(r.scan("item-closed").size).to eq(2) # there are two of each
  end

  it "handles type update from pointer" do
    pointer_card = create_pointer "PointerToSearches"
    pointer_card.update! type_id: Card::SearchTypeID, content: %({"type":"User"})
    expect(pointer_card.content).to eq(%({"type":"User"}))
  end

  context "references" do
    subject do
      Card["search with references"]
    end

    before do
      create_search_type "search with references", content: '{"name":"Y"}'
    end

    it "updates query if referee changed" do
      Card["Y"].update! name: "YYY"
      expect(subject.content).to eq '{"name":"YYY"}'
    end
  end

  describe "rss format" do
    it "render rss without errors" do
      with_rss_enabled do
        search_card = Card.create type: "Search", name: "Asearch", content: %({"id":"1"})
        rss = search_card.format(:rss).render_feed
        expect(rss).to have_tag("title", text: "Decko Bot")
      end
    end
  end

  describe "json" do
    include_context "with json context"

    def card_subject
      sample_search
    end

    let(:item_names) { ["50 grades of shy", "Iliad", "Parry Hotter"] }

    specify "view: links" do
      expect_view(:links, format: :json).to eq([])
    end

    describe "view: items" do
      it "returns atom values for items" do
        expect_view(:items, format: :json)
          .to include(*item_names.map { |i| structured_atom_values Card[i] })
      end

      it "returns all items" do
        expect(view(:items, card: card_subject, format: :json).size).to eq 3
      end

      context "with paging" do
        def paging_url offset
          json_url card_subject.name.url_key, "item=name&limit=1&offset=#{offset}"
        end

        let(:paging_values) do
          view(:molecule, card: card_subject, format: :json)[:paging]
        end

        before do
          Card::Env.params[:limit] = 1
        end

        it "shows next link" do
          expect(paging_values).to eq(next: paging_url(1))
        end

        it "shows next and previous link" do
          Card::Env.params[:offset] = 1
          expect(paging_values).to eq(next: paging_url(2), previous: paging_url(0))
        end

        it "shows previous link" do
          Card::Env.params[:offset] = 2
          expect(paging_values).to eq(previous: paging_url(1))
        end
      end
    end
  end
end
