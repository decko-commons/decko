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
        %w[https://code.jquery.com/jquery-3.6.0.min.js
           https://cdnjs.cloudflare.com/ajax/libs/jquery-ujs/1.2.0/rails.min.js
           /files/:mod_script_script_asset_output/script.js
           /files/:mod_ace_editor_script_asset_output/ace_editor.js
           /files/:mod_bootstrap_script_asset_output/bootstrap.js
           /files/:mod_date_script_asset_output/date.js
           /files/:mod_tinymce_editor_script_asset_output/tinymce_editor.js]
          .each do |src|
            is_expected.to have_tag(:script, with: { src: src })
          end
      end
    end

    it "has a main stylesheets link" do
      is_expected.to have_tag(
        :link, with: { rel: "stylesheet", media: "all", type: "text/css",
                       href: "/files/:all_style_asset_output/defaults.css" }
      )
    end

    it "handles tinyMCE configuration" do
      is_expected.to match(/decko\.setTinyMCEConfig/)
    end

    it "triggers slotReady" do
      is_expected.to match(/trigger\W*slotReady/)
    end

    it "sets rootUrl" do
      is_expected.to match(/decko\.rootUrl/)
    end
  end
end
