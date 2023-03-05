RSpec.describe Card::Set::All::History::Actions do
  context "when changing content" do
    let :card do
      "basicname".card.tap { |c| c.update! content: "foo" }
    end

    specify "#actions"  do
      expect(card.actions.count).to eq(2)
    end

    specify "#nth_action" do
      expect(card.nth_action(1).value(:db_content)).to eq("basiccontent")
    end
  end
end
