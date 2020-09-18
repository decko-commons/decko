# -*- encoding : utf-8 -*-

version = File.open(File.expand_path("../../card/VERSION", __FILE__)).read.chomp

vbits = version.split('.').map &:to_i
vplus = { 0 => 90, 1 => 100 } # can remove and hardcode after 1.0
vminor = vplus[ vbits[0] ] + vbits[1]
card_version = [1, vminor, vbits[2]].compact.map(&:to_s).join "."
# see card.gemspec for explanation of all of this, which has been ham-handedly
# cut and pasted here.


Gem::Specification.new do |s|
  s.name          = "decko"
  s.version       = version
  s.authors       = ["Ethan McCutchen", "Philipp Kühl", "Lewis Hoffman", "Gerry Gleason"]
  s.email         = ["info@decko.org"]

  #  s.date          = '2013-12-20'
  s.summary       = "structured wiki web platform"
  s.description   = "a wiki approach to stuctured data, dynamic interaction, "\
                    " and web design"
  s.homepage      = "http://decko.org"
  s.licenses      = ["GPL-2.0", "GPL-3.0"]

  s.files         = Dir["README.rdoc", "LICENSE", "GPL",
                        "{app,bin,lib,rails,script}/**/*"]

  s.bindir        = "bin"
  s.executables   = ["decko"]
  s.require_paths = ["lib"]

  s.required_ruby_version = ">= 2.5"

  [["card", card_version]].each do |dep|
    s.add_runtime_dependency(*dep)
  end
end
