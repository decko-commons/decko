# -*- encoding : utf-8 -*-

require "../decko_gem"

DeckoGem.gem "decko-rails" do |s, d|
  s.summary = "rails engine for decko: a structured wiki web platform"
  s.description = "Provides the glue to make decko available as a Rails::Engine."

  s.files = Dir["lib/*/**"]
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  d.depends_on ["decko", d.decko_version]
end
