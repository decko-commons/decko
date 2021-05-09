# -*- encoding : utf-8 -*-

describe Card::Action do
  describe "#delete_old_actions" do
    it "puts all changes on one action" do
      a = Card["A"]
      a.update!(name: "New A")
      a.update!(content: "New content")
      a.clear_history
      expect(a.actions.count).to eq(1)
      expect(a.actions.last.card_changes.count).to eq(0)
      expect(a.actions.reload.last.value(:name)).to eq("New A")
    end
  end
end
