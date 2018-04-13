# -*- encoding : utf-8 -*-

describe Card::Set::Self::Head do
  subject { render_card :core, name: "*head" }

  describe "head tag" do
    it "has (a) meta tag(s)" do
      is_expected.to have_tag(:meta, with: { charset: "UTF-8" })
    end

    it "has a title" do
      is_expected.to have_tag(:title, text: "*head - My Deck")
    end

    it "has a favicon" do
      is_expected.to have_tag(:link,
                              with: { rel: "shortcut icon",
                                      href: "/files/:favicon/standard-small.png" })
    end

    it "has a main javascript tag" do
      is_expected.to have_tag(
        :script, with: { src: "/files/:all_script_machine_output/machines.js" }
      )
    end

    it "has a main stylesheets link" do
      is_expected.to have_tag(
        :link, with: { rel: "stylesheet", media: "all", type: "text/css",
                       href: "/files/:all_style_machine_output/machines.css" }
      )
    end

    it "handles tinyMCE configuration" do
      is_expected.to match(/decko\.setTinyMCEConfig/)
    end

    it "triggers slotReady" do
      is_expected.to match(/trigger\W*slotReady/)
    end

    it "sets rootPath" do
      is_expected.to match(/window\.decko\W+rootPath/)
    end
  end
end
