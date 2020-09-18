# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::All::ReferenceEditor::NestEditor::NestParser do
  def parse nest
    described_class.new nest, :titled, :bar
  end

  context "with field" do
    let(:parser) do
      parse "{{+hi|view: open; show: menu, toggle; wrap: slot; invalid: x"\
                      "|view: titled; hide: header, footer"\
                      "|content; title: subsub}}"
    end

    it "removes + from name" do
      expect(parser.name).to eq "hi"
    end

    specify "#field?" do
      expect(parser.field?).to eq true
    end

    specify "#options" do
      expect(parser.options)
        .to eq [[:view, "open"], [:show, "menu"], [:show, "toggle"], [:wrap, "slot"]]
    end

    specify "#item_options" do
      expect(parser.item_options)
        .to eq [[[:view, "titled"], [:hide, "header"], [:hide, "footer"]],
                [[:view, "content"], [:title, "subsub"]]]
    end
  end

  context "with non-field" do
    let(:parser) do
      parse "{{hi|open; show: menu|view: titled}}"
    end

    specify "name" do
      expect(parser.name).to eq "hi"
    end

    specify "#field?" do
      expect(parser.field?).to eq false
    end

    specify "#options" do
      expect(parser.options)
        .to eq [[:view, "open"], [:show, "menu"]]
    end
  end
end
