# -*- encoding : utf-8 -*-

require "../decko_gem"

DeckoGem.gem "decko" do |s, d|
  s.summary = "structured wiki web platform"
  s.description =
    "a wiki approach to structured data, dynamic interaction,  and web design"

  s.files = Dir["{app,bin,lib,rails,script}/**/*"]

  s.bindir = "bin"
  s.executables = ["decko"]
  s.add_runtime_dependency "card", d.card_version

  # TODO: remove following.
  # It is just a temporary fix so that old sites continue to work without having to
  # edit their Gemfile.
  d.depends_on_mod :defaults
end
