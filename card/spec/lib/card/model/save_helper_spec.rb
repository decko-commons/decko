RSpec.describe Card::Model::SaveHelper, as_bot: true do
  describe "#ensure_card" do
    after do
      Card::Codename.reset_cache
    end

    it "creates card if card doesn't exist" do
      ensure_card "ensured card"
      expect_card("ensured card").to exist
    end

    it "updates card if card exists" do
      ensure_card "*home", type_id: Card::PhraseID
      expect_card("*home").to have_type :phrase
    end

    example "content string argument" do
      ensure_card "A", "new content"
      expect_card("A").to have_content "new content"
    end

    example "single hash argument" do
      ensure_card name: "A", content: "new content"
      expect_card("A").to have_content "new content"
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

    it "doesn't fail if codename doesn't exist" do
      ensure_card :not_a_codename, name: "test", codename: "with_codename"
      expect_card(:with_codename).to exist
    end

    it "changes codename" do
      ensure_card :home, codename: "new_home"
      expect(Card::Codename.exist?(:home)).to be_falsey
      expect_card(:new_home).to exist
    end
  end

  describe "#ensure_card!" do
    it "changes name variant"  do
      ensure_card! "*Home"
      expect_card(:home).to have_name "*Home"
    end
  end
end
