# -*- encoding : utf-8 -*-

require "../decko_gem"

DeckoGem.gem "decko" do |s, d|
  s.required_ruby_version ">= 3.0.0"
  s.summary = "structured wiki web platform"
  s.description =
    "a wiki approach to structured data, dynamic interaction,  and web design"

  s.files = Dir["{app,bin,lib,config,script}/**/*"]

  s.bindir = "bin"
  s.executables = ["decko"]
  s.add_runtime_dependency "actionpack", d.rails_version
  s.add_runtime_dependency "card", d.card_version

  # TODO: remove following.
  # It is just a temporary fix so that old sites continue to work without having to
  # edit their Gemfile.
  d.depends_on_mod :defaults
end
