# -*- encoding : utf-8 -*-

require "../../../decko_gem"

Gem::Specification.new do |s|
  DeckoGem.shared s
  DeckoGem.mod s, "defaults"
  DeckoGem.depends_on_mod s, :ace_editor, :prosemirror_editor, :recaptcha,
                          :tinymce_editor, :markdown, :date, :google_analytics,
                          :carrierwave, :bootstrap, :follow

  s.summary = "Default decko mods"
  s.description = ""
end
