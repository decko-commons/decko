# -*- encoding : utf-8 -*-

describe Card::Format do
  describe "#show_view?" do
    let(:format) { described_class.new Card.new }

    def show_menu? args, default_viz=:show
      args.merge! optional: true
      format.with_voo(Card::View.new format, :nonview, args) do
        format.show_view?(:menu, default_viz)
      end
    end

    it "respects defaults" do
      expect(show_menu?({}, :show)).to be_truthy
      expect(show_menu?({}, :hide)).to be_falsey
      expect(show_menu?({})).to be_truthy
    end

    it "respects developer defaults" do
      expect(show_menu?({ show: "menu" }, :hide)).to be_truthy
      expect(show_menu?({ hide: "menu" }, :show)).to be_falsey
      expect(show_menu?(hide: "menu")).to be_falsey
    end

    it "handles args from nests" do
      expect(show_menu?({ show: "menu" }, :hide)).to be_truthy
      expect(show_menu?({ hide: "menu, paging" }, :show)).to be_falsey
      expect(show_menu?({ show: "menu" }, :hide)).to be_truthy
    end
  end

  describe "format helpers and link building" do
    before :each do
      # should be a way to get these defaults in these tests
      Card::Env[:host] = "//test.host"
      Card::Env[:protocol] = "http:"
    end

    let(:card) { Card["Home"] }
    let(:text_format) { card.format(:text) }
    let(:html_format) { card.format }
    let(:url_text1) do
      "with external free link http://localhost:2020/path?cgi=foo&bar=baz"
    end
    let(:url_text2) { "with external in link syntax: [[http://brain.org/Home|extra]]" }
    let(:url_text3) { "with internal lik [[A]]" }
    let(:url_text4) { "with internal lik [[Home|display text]]" }
    let(:url_text5) do
      "external with port: http://localhost:2020/path?cgi=foo+bar=baz after "
    end

    it "formats links" do
      cobj = Card::Content.new url_text1, text_format
      expect(cobj.to_s).to eq url_text1
      cobj = Card::Content.new url_text2, text_format
      expect(cobj.to_s).to eq url_text2
      cobj = Card::Content.new url_text3, text_format
      expect(cobj.to_s).to eq url_text3
      cobj = Card::Content.new url_text4, text_format
      expect(cobj.to_s).to eq url_text4
      cobj = Card::Content.new url_text5, text_format
      expect(cobj.to_s).to eq url_text5
    end

    it "formats html links" do
      cobj = Card::Content.new url_text1, html_format
      expect(cobj.to_s).to eq(
                             'with external free link <a target="_blank" class="external-link" ' \
        'href="http://localhost:2020/path?cgi=foo&amp;bar=baz">' \
        "http://localhost:2020/path?cgi=foo&bar=baz</a>"
                           )
      cobj = Card::Content.new url_text2 + url_text3 + url_text4, html_format
      expect(cobj.to_s).to eq url_text2 + url_text3 + url_text4
      cobj = Card::Content.new url_text5, html_format
      expect(cobj.to_s).to eq(
                             'external with port: <a target="_blank" class="external-link" ' \
        'href="http://localhost:2020/path?cgi=foo+bar=baz">' \
        "http://localhost:2020/path?cgi=foo+bar=baz</a> after "
                           )
    end

    it "formats path" do
      expect(text_format.path(card.name)).to eq "/" + card.name
      expect(html_format.path(card.name)).to eq "/" + card.name
      path = html_format.path mark: card.name, format: "txt", opt1: 11, opt2: "foo"
      expect(path).to eq "/#{card.name}.txt?opt1=11&opt2=foo"
    end

    it "fomats full path and url" do
      expect(text_format.card_path(card.name)).to eq "/#{card.name}"
      expect(html_format.card_url(card.name))
        .to eq "http://test.host/#{card.name}"
    end
  end

  describe "async view" do
    let(:format) do
      Card["A"].format_with do
        view :lazy_view, async: true do
          "content"
        end
      end
    end

    it "renders placeholder" do
      expect(format.render!(:lazy_view))
        .to eq %(<card-view-placeholder data-url="/A?view=lazy_view_async_content" />)
    end

    it "renders content in _async_content view" do
      expect(format.render!(:lazy_view_async_content))
        .to eq "content"
    end
  end
end
