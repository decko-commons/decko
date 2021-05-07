RSpec.describe Card::Set::All::Alias do
  let(:original_name) { "T" }
  let(:target) { Card["T"] }
  let(:new_name) { "TT" }

  describe "event: create_alias_upon_rename" do
    specify do
      target.update! name: new_name, trigger: :create_alias_upon_rename
      source = Card[original_name]
      expect(source.type_code).to eq(:alias)
      expect(source.target_name).to eq(new_name)
    end
  end
end
