RSpec.describe Card::Model::SaveHelper, as_bot: true do
  describe "#ensure_card" do
    it "creates card when card doesn't exist" do
      ensure_card "ensured card"
      expect_card("ensured card").to exist
    end

    example "content argument" do
      ensure_card "*home", "new content"
      expect_card("*home").to have_content "new content"
    end

    it "updates attributes" do
      ensure_card "*home", type_id: Card::PhraseID
      expect_card("*home").to have_type :phrase
    end

    it "doesn't change name variant"  do
      ensure_card "*Home"
      expect_card(:home).to have_name "*home"
    end

    it "changes name if new name is given" do
      ensure_card "*home", name: "new home"
      expect_card("*home").not_to exist
      expect_card("new home").to exist
    end

    it "renames existing codename cards" do
      expect_card("*home").to exist
      ensure_card :home, name: "New Home"
      expect_card("*home").not_to exist
      expect(Card[:home].name).to eq "New Home"
    end
  end

  describe "#ensure_card!" do
    it "changes name variant"  do
      ensure_card! "*Home"
      expect_card(:home).to have_name "*Home"
    end
  end
end
