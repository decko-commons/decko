RSpec.describe Card::Model::SaveHelper do
  it "renames existing codename cards" do
    expect_card("*home").to exist
    ensure_card :home, name: "New Home"
    expect_card("*home").not_to exist
    expect(Card[:home].name).to eq "New Home"
  end
end
