describe Card::Set::All::History::Revision do
  describe "#revision" do
    example "updated card", as_bot: true do
      update "T", "undo me"
      res = Card["T"].revision Card["T"].actions.last, true
      expect(res).to eq(db_content: "Theta", name: "T", trash: "f", type_id: "3")
    end

    example "created card", as_bot: true do
      create "Im new", "hello"
      res = Card["T"].revision Card["T"].actions.last, true
      expect(res).to eq(trash: true)
    end

    example "deleted and recreated card with same content", as_bot: true do
      Card["T"].delete
      create "T", "Theta"
      update "T", "undo me"
      res = Card["T"].revision Card["T"].actions.last, true
      expect(res).to eq(db_content: "Theta", name: "T", trash: "f", type_id: "3")
    end

    example "deleted and recreated card with changed content", as_bot: true do
      Card["T"].delete
      create "T", "reborn"
      update "T", "undo me"
      res = Card["T"].revision Card["T"].actions.last, true
      expect(res).to eq(db_content: "reborn", name: "T", trash: "f", type_id: "3")
    end
  end
end
