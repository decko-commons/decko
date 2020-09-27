# -*- encoding : utf-8 -*-

require "../decko_gem"

DeckoGem.gem "decko-rails" do |s, d|
  s.summary = "rails engine for decko: a structured wiki web platform"
  s.description = "Provides the glue to make decko available as a Rails::Engine."

  s.files = Dir["lib/*/**"]
  s.test_files = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  s.add_runtime_dependency "decko", d.decko_version
end
