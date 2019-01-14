# -*- encoding : utf-8 -*-

describe Card::Set::All::Error do
  describe "missing view" do
    it "prompts to add" do
      expect(render_content("{{+cardipoo|open}}")).to match(/fa-plus-square.*cardipoo/)
    end
  end
end
