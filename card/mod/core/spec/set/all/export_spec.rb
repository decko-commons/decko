# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::All::Export do
  describe "rendering json in export mode" do
    before do
      Card::Env.params[:max_export_depth] = 4
    end

    def export_pointer content, type=:pointer
      export_name = "#{type} export card"
      create export_name, type: type, content: content

      create("export pointer", type_id: Card::PointerID, content: export_name)
        .format(:json).render_export
    end

    context "pointer card" do
      it "contains cards in the pointer card and its children" do
        expect(export_pointer(%w[T A+B])).to include(
          a_hash_including(name: "pointer export card", type: "Pointer",
                           content: "[[T]]\n[[A+B]]"),
          a_hash_including(name: "T", type: "RichText", content: "Theta"),
          a_hash_including(name: "A+B", type: "RichText", content: "AlphaBeta")
        )
      end
      it "handles multi levels pointer cards" do
        inner_pointer = create "inner pointer", type: :pointer, content: "T"
        expect(export_pointer([inner_pointer.name, "A+B"])).to include(
          a_hash_including(name: "pointer export card", type: "Pointer",
                           content: "[[inner pointer]]\n[[A+B]]"),
          a_hash_including(name: "inner pointer", type: "Pointer",
                           content: "[[T]]"),
          a_hash_including(name: "T", type: "RichText", content: "Theta"),
          a_hash_including(name: "A+B", type: "RichText", content: "AlphaBeta")
        )
      end

      it "stops while the depth count > 10" do
        expect(export_pointer("pointer export card"))
          .to include(
            a_hash_including(name: "pointer export card",
                             type: "Pointer",
                             content: "[[pointer export card]]")
          )
      end
    end

    context "skin card" do
      it "contains cards in the pointer card and its children" do
        export = export_pointer("[[T]]", :skin)
        expect(export).to include(
          a_hash_including(name: "skin export card", type: "Skin",
                           content: "[[T]]"),
          a_hash_including(name: "T", type: "RichText", content: "Theta")
        )
      end
    end

    context "search card" do
      it "contains cards from search card and its children" do
        expect(export_pointer('{"left":"A"}', :search_type)).to include(
          a_hash_including(name: "search_type export card", type: "Search",
                           content: '{"left":"A"}'),
          a_hash_including(name: "A+B", content: "AlphaBeta", type: "RichText"),
          a_hash_including(name: "A+C", type: "RichText")
        )
      end
    end
  end
end
