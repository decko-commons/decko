# -*- encoding : utf-8 -*-

require "../../decko_gem"

DeckoGem.mod "tinymce_editor" do |s, d|
  required_ruby_version = ">= 3.0.0"
  d.depends_on_mod :edit
  s.summary = "TinyMCE editor"
  s.description = ""
end
