# -*- encoding : utf-8 -*-

require "../../decko_gem"

DeckoGem.mod "carrierwave" do |s, d|
  s.required_ruby_version ">= 3.0.0"
  s.summary = "File and Image handling"
  s.description = ""
  d.depends_on ["carrierwave", "~> 3.0"],
               ["mini_magick", "~> 4.12"],
               ["ssrf_filter", "~> 1.1"],
               ["marcel", "1.0.2"]
  # remove marcel row soon.
  # currently 1.0.4 breaks mod/carrierwave/spec/set/type/file_spec.rb, but
  # presumably a carrierwave update will fix that soon

  d.depends_on_mod :history, :permissions
end
