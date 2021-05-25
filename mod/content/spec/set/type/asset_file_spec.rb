# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::AssetFile do
  it"loads content from file" do
    path = File.join(__dir__ , "asset_file.txt")
    card = Card.new name: "test", type_id: Card::AssetFileID, content: path
    expect(card.content).to eq "test content\n"
  end
end
