# -*- encoding : utf-8 -*-

require "../decko_gem"

DeckoGem.gem do |s, d|
  s.name = "decko-rails"
  s.version = s.decko_version

  s.summary = "rails engine for decko: a structured wiki web platform"
  s.description = "Provides the glue to make decko available as a Rails::Engine."

  s.files = Dir["lib/*/**"]
  s.test_files = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  s.add_runtime_dependency "decko", s.decko_version
end
