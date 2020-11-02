RSpec.describe Card::Set::All::Chunk do
  describe "#edit_fields" do
    def format_with_edit_fields args
      Card["A"].format_with(:html) do
        define_method :edit_fields do
          args
        end
      end
    end

    it "interprets strings as field names" do
      format = format_with_edit_fields ["B", "+C"]
      expect(format.render_edit).to have_tag ".card-slot" do
        with_tag ".card-editor.RIGHT-b", with: { card_name: "A+B" }
        with_tag ".card-editor.RIGHT-c", with: { card_name: "A+C" }
      end
    end

    it "doesn't make card objects to fields" do
      format = format_with_edit_fields [Card["B"]]
      expect(format.render_edit).to have_tag ".card-editor", with: { card_name: "B" }
    end

    it "treats symbols as codenames", as_bot: true do
      format = format_with_edit_fields [:write, :basic]
      expect(format.render_edit).to have_tag ".card-slot" do
        with_tag ".card-editor.RIGHT-Xwrite", with: { card_name: "A+*write" }
        with_tag ".card-editor.RIGHT-rich_text", with: { card_name: "A+RichText" }
      end
    end

    example "absolute option", as_bot: true do
      format = format_with_edit_fields [[:self, { absolute: true }]]

      expect(format.render_edit).to have_tag ".card-editor", with: { card_name: "*self" }
    end

    example "title argument" do
      format = format_with_edit_fields [["B", "custom title"]]
      expect(format.render_edit)
        .to have_tag ".card-editor.RIGHT-b", with: { card_name: "A+B" } do
        with_tag ".card-title", text: "custom title"
      end
    end
  end
end
