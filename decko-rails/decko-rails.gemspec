# -*- encoding : utf-8 -*-

# lib = File.expand_path('../lib', __FILE__)
# $LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
version = File.open(File.expand_path("../../card/VERSION", __FILE__)).read.chomp

Gem::Specification.new do |s|
  s.name          = "decko-rails"
  s.version       = version
  s.authors       = ["Ethan McCutchen", "Gerry Gleason", "Philipp Kühl"]
  s.email         = ["info@decko.org"]

  #  s.date          = '2013-12-20'
  s.summary       = "rails engine for decko: a structured wiki web platform"
  s.description   = "Provides the glue to make decko available as a Rails::Engine."
  s.homepage      = "http://decko.org"
  s.licenses      = ["GPL-2.0", "GPL-3.0"]

  s.files         = Dir["lib/*/**"]

  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  s.required_ruby_version = ">= 1.8.7"

  s.add_runtime_dependency "decko", version
end
