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
      is_expected.to have_tag(:link, with: { rel: "shortcut icon",
                                             href: "/files/:favicon/standard-small.png" })
    end

    it "has a main javascript tag" do
      aggregate_failures do
        %w[:mod_script_script_decko_machine_output/script.js
           :mod_ace_editor_script_local_machine_output/ace_editor.js
           :mod_bootstrap_script_bootstrap_machine_output/bootstrap.js
           :mod_bootstrap_script_pointer_machine_output/bootstrap.js
           :mod_date_script_datepicker_machine_output/date.js
           :mod_prosemirror_editor_script_local_machine_output/prosemirror_editor.js
           :mod_tinymce_editor_script_local_machine_output/tinymce_editor.js]
          .each do |src|
            is_expected.to have_tag(:script, with: { src: "/files/#{src}" })
          end
      end
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

    it "sets rootUrl" do
      is_expected.to match(/window\.decko\W+rootUrl/)
    end
  end
end
