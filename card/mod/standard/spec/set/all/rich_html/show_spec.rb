RSpec.describe Card::Set::All::RichHtml::Show do
  describe "show with layout" do
    let(:show) { Card["stacks"].format.show nil, {} }

    it "renders with layout card rule" do
      expect(show).to include "Callahan"
    end
  end
end
