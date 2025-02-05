# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Self::Head do
  subject { render_card :core, name: "*head" }

  describe "head tag" do
    it "has (a) meta tag(s)" do
      is_expected.to have_tag(:meta, with: { charset: "UTF-8" })
    end

    it "has a title" do
      is_expected.to have_tag(:title, text: "*head - My Deck")
    end

    it "has a favicon" do
      favpath = "/files/:favicon/carrierwave-small.png"
      is_expected
        .to have_tag(:link, with: { rel: "shortcut icon", href: favpath })
    end

    it "has a main javascript tag" do
      aggregate_failures do
        %w[https://code.jquery.com/jquery-3.5.1.min.js
           https://cdnjs.cloudflare.com/ajax/libs/jquery-ujs/1.2.3/rails.min.js
           /files/:mod_format+:script+:asset_output/format.js
           /files/:mod_ace_editor+:script+:asset_output/ace_editor.js
           /files/:mod_bootstrap+:script+:asset_output/bootstrap.js
           /files/:mod_tinymce_editor+:script+:asset_output/tinymce_editor.js]
          .each do |src|
            is_expected.to have_tag(:script, with: { src: src })
          end
      end
    end

    it "has a main stylesheets link" do
      is_expected.to have_tag(
        :link, with: { rel: "stylesheet", media: "all", type: "text/css",
                       href: "/files/:all+:style+:asset_output/defaults.css" }
      )
    end

    it "handles tinyMCE configuration" do
      is_expected.to match(/decko\.setTinyMCEConfig/)
    end

    it "triggers decko.slot.ready" do
      is_expected.to match(/trigger\W*decko.slot.ready/)
    end

    it "sets rootUrl" do
      is_expected.to match(/decko\.rootUrl/)
    end
  end
end
