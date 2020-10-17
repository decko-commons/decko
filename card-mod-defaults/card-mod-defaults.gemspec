# -*- encoding : utf-8 -*-

require "../decko_gem"

DeckoGem.mod "defaults" do |s, d|
  d.depends_on_mod :account, :ace_editor, :bar_and_box, :bootstrap, :carrierwave,
                   :date, :delayed_job, :follow, :google_analytics, :history,
                   :machines, :markdown, :prosemirror_editor, :recaptcha, :rules,
                   :search, :tinymce_editor
  s.summary = "Default decko mods"
  s.description = ""
end
