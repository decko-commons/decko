RSpec.describe Card::Set::All::FormElements do
  describe "#hidden_tags" do
    def hidden_tags opts
      Card["A"].format.hidden_tags opts
    end

    example "simple argument" do
      expect(hidden_tags(a: "val"))
        .to have_tag :input, with: { type: "hidden", name: "a", value: "val" }
    end

    example "deep nested arguments" do
      tags = hidden_tags a: { b: { c: "val1" }, d: "val2" }, x: { y: "val3" }
      aggregate_failures do
        expect(tags)
          .to have_tag(:input, with: { type: "hidden", name: "a[b][c]", value: "val1" })
        expect(tags)
          .to have_tag(:input, with: { type: "hidden", name: "a[d]", value: "val2" })
        expect(tags)
          .to have_tag(:input, with: { type: "hidden", name: "x[y]", value: "val3" })
      end
    end

    describe "array values" do
      let(:tags) { hidden_tags(a: { b: [1, 2] }) }

      example "first array value" do
        expect(tags)
          .to have_tag(:input, with: { type: "hidden", name: "a[b][]", value: "1" })
      end

      example "second array value" do
        expect(tags)
          .to have_tag(:input, with: { type: "hidden", name: "a[b][]", value: "2" })
      end
    end
  end
end
