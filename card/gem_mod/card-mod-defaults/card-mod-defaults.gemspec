# -*- encoding : utf-8 -*-

require "../../../decko_gem"

Gem::Specification.new do |s|
  DeckoGem.shared s
  DeckoGem.mod s, "defaults"
  DeckoGem.mod_depend s, :ace_editor, :prosemirror_editor, :recaptcha, :tinymce_editor,
                      :markdown, :date

  s.summary       = "Default decko mods"
  s.description   = ""
  s.files         = Dir["README.md"]
end
