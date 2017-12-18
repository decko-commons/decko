RSpec.describe Card::View::Options do
  describe "#add_option" do
    specify do
      expect(Card::View::Options.all_keys).not_to include :new_option
      Card::View::Options.add_option :new_option, :carditect
      expect(Card::View::Options.all_keys).to include :new_option
    end
  end
end
