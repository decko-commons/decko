RSpec.describe Card::Set::All::RichHtml::FormElements do
  describe "#hidden_tags" do
    def hidden_tags opts
      Card["A"].format.hidden_tags opts
    end

    example "simple argument" do
      expect(hidden_tags(a: "val"))
        .to have_tag :input, with: { type: "hidden", name: "a", value: "val"}
    end

    example "deep nested arguments" do
      expect(hidden_tags(a: { b: { c: "val" } }))
        .to have_tag :input, with: { type: "hidden", name: "a[b][c]", value: "val"}
    end
  end
end
