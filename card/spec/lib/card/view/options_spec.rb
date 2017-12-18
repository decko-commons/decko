RSpec.describe Card::View::Options do
  specify "#add_option" do
    expect(Card::View::Options.all_keys).not_to include :new_option
    Card::View::Options.add_option :new_option, :carditect
    expect(Card::View::Options.all_keys).to include :new_option
  end

  describe "#accessible keys" do
    specify "accessible keys" do
      expect(Card::View::Options.accessible_keys)
        .to include :nest_name, :nest_syntax, :main, :home_view, :edit_structure, :wql,
                    :help, :structure, :title, :variant, :editor, :type, :size, :params,
                    :items, :cache, :skip_perms, :main_view
    end

    specify "non-accessible keys" do
      expect(Card::View::Options.accessible_keys)
        .not_to include :view, :show, :hide
    end
  end
end
