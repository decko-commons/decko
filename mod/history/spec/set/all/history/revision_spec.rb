RSpec.describe Card::Set::All::History::Revision do
  let :theta_revision do
    {
      db_content: "Theta",
      name: "T",
      trash: "f",
      type_id: :basic.card_id.to_s,
      left_id: nil,
      right_id: nil
    }
  end

  describe "#revision" do
    example "updated card", :as_bot do
      update "T", "undo me"
      res = Card["T"].revision Card["T"].actions.last, true
      expect(res).to eq(theta_revision)
    end

    example "created card", :as_bot do
      create "Im new", "hello"
      res = Card["T"].revision Card["T"].actions.last, true
      expect(res).to eq(trash: true)
    end

    example "deleted and recreated card with same content", :as_bot do
      Card["T"].delete
      create "T", "Theta"
      update "T", "undo me"
      res = Card["T"].revision Card["T"].actions.last, true
      expect(res).to eq(theta_revision)
    end

    example "deleted and recreated card with changed content", :as_bot do
      Card["T"].delete
      create "T", "reborn"
      update "T", "undo me"
      res = Card["T"].revision Card["T"].actions.last, true
      expect(res).to eq(theta_revision.merge(db_content: "reborn"))
    end
  end
end
