RSpec.describe Card::Model::SaveHelper, as_bot: true do
  describe "Card#ensure" do
    after do
      Card::Codename.reset_cache
    end

    it "creates card if card doesn't exist" do
      Card.ensure name: "ensured card"
      expect_card("ensured card").to exist
    end

    it "updates card if card exists" do
      Card.ensure name: "*home", type_id: Card::PhraseID
      expect_card("*home").to have_type :phrase
    end

    example "content string argument" do
      Card.ensure name: "A", content: "new content"
      expect_card("A").to have_content "new content"
    end

    example "single hash argument" do
      Card.ensure name: "A", content: "new content"
      expect_card("A").to have_content "new content"
    end

    it "doesn't change name variant"  do
      Card.ensure name: "*Home"
      expect_card(:home).to have_name "*home"
    end

    it "changes name if new name is given" do
      Card.ensure name: "*home", name: "new home"
      expect_card("*home").not_to exist
      expect_card("new home").to exist
    end

    it "renames existing codename cards" do
      expect_card("*home").to exist
      Card.ensure name: :home, name: "New Home"
      expect_card("*home").not_to exist
      expect(Card[:home].name).to eq "New Home"
    end

    it "doesn't fail if codename doesn't exist" do
      Card.ensure name: :not_a_codename, name: "test", codename: "with_codename"
      expect_card(:with_codename).to exist
    end

    it "changes codename" do
      Card.ensure name: :home, codename: "new_home"
      expect(Card::Codename).not_to be_exist(:home)
      expect_card(:new_home).to exist
    end
  end

  describe "#Card.ensure!" do
    it "changes name variant"  do
      Card.ensure! "*Home"
      expect_card(:home).to have_name "*Home"
    end
  end
end
