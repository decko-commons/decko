RSpec.describe Card::View::Options do
  describe "#add_option" do
    let(:option_keys) { described_class.all_keys }
    it "does not have :new_option by default" do
      expect(option_keys).not_to include(:new_option)
    end

    it "has that option after being called" do
      described_class.add_option :new_option, :shark
      expect(option_keys).to include(:new_option)
    end
  end

  describe "#accessible keys" do
    subject { described_class.accessible_keys }
    specify "accessible keys" do
      is_expected.to include *%i[nest_name nest_syntax main home_view edit_structure wql
                                 help structure title variant editor type size params
                                 items cache skip_perms main_view]
    end

    specify "non-accessible keys" do
      is_expected.not_to contain_exactly :view, :show, :hide
    end
  end

  describe "#normalize_special_options!" do
    before do
      sample_voo.normalize_special_options! options
    end

    let(:options) { { editor: "list", layout: "simple, default", cache: "never" } }

    it "normalizes editor option to symbol" do
      expect(options[:editor]).to eq(:list)
    end

    it "normalizes cache option to symbol" do
      expect(options[:cache]).to eq(:never)
    end

    it "normalizes layout option to array of symbols" do
      expect(options[:layout]).to eq(%i[simple default])
    end
  end

  describe "#normalize_layout" do
    it "converts single layouts to arrays" do
      expect(sample_voo.normalize_layout("simple")).to eq([:simple])
    end

    it "works when layout is already a symbol" do
      expect(sample_voo.normalize_layout(:simple)).to eq([:simple])
    end

    it "works when layout is already an array" do
      expect(sample_voo.normalize_layout([:simple, "default"])).to eq(%i[simple default])
    end
  end
end
