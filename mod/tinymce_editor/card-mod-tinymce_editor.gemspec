# -*- encoding : utf-8 -*-

require "../../decko_gem"

DeckoGem.mod "tinymce_editor" do |s, d|
  d.depends_on_mod :edit
  d.required_ruby_version ">= 3.0.0"
  s.summary = "TinyMCE editor"
  s.description = ""
end
