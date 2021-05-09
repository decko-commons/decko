require_relative "../../../../../card/lib/card/tasks/card/file_card_creator"

RSpec.describe Card::FileCardCreator::ScriptCard do
  it "accepts type js" do
    expect(described_class).to be_valid_type(:js)
  end

  it "accepts type coffee" do
    expect(described_class).to be_valid_type(:coffee)
  end

  specify "#category" do
    dc = described_class.new "mod", "name", "js"
    expect(dc.category).to eq :script
  end
end
