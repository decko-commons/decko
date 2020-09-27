# -*- encoding : utf-8 -*-

require "../decko_gem"

DeckoGem.mod "defaults" do |s, _d|
  d.depends_on_mod :ace_editor, :prosemirror_editor, :recaptcha, :tinymce_editor, :follow,
                   :markdown, :date, :google_analytics, :carrierwave, :bootstrap
  s.summary = "Default decko mods"
  s.description = ""
end
