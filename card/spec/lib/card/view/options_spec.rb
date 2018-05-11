RSpec.describe Card::View::Options do
  specify "#add_option" do
    expect(Card::View::Options.all_keys).not_to include :new_option
    Card::View::Options.add_option :new_option, :ruler
    expect(Card::View::Options.all_keys).to include :new_option
  end

  describe "#accessible keys" do
    specify "accessible keys" do
      expect(Card::View::Options.accessible_keys)
        .to include *%i[nest_name nest_syntax main home_view edit_structure wql
                        help structure title variant editor type size params
                        items cache skip_perms main_view]
    end

    specify "non-accessible keys" do
      expect(Card::View::Options.accessible_keys)
        .not_to contain_exactly :view, :show, :hide
    end
  end
end
