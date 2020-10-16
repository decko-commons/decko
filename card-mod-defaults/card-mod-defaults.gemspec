# -*- encoding : utf-8 -*-

require "../decko_gem"

DeckoGem.mod "defaults" do |s, d|
  d.depends_on_mod :ace_editor, :prosemirror_editor, :recaptcha, :tinymce_editor, :follow,
                   :markdown, :date, :google_analytics, :carrierwave, :bootstrap,
                   :account, :history, :delayed_job, :rules, :bar_and_box
  s.summary = "Default decko mods"
  s.description = ""
end
