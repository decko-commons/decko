# -*- encoding : utf-8 -*-

# Helper methods for gem specs and gem-related tasks
class DeckoGem < Gem::Specification
  VERSION = File.open(File.expand_path("../card/VERSION", __FILE__)).read.chomp
  CARD_MINOR = { 0 => 90, 1 => 1000 }.freeze # can remove and hardcode after 1.0

  def initialize
    super.tap { shared }
  end

  def decko_version
    VERSION
  end

  def card_version
    [1, minor, point].compact.map(&:to_s).join "."
  end

  def shared
    self.authors = ["Ethan McCutchen", "Philipp Kühl", "Gerry Gleason"]
    self.email = ["info@decko.org"]
    self.homepage = "http://decko.org"
    self.licenses = ["GPL-2.0", "GPL-3.0"]
    self.required_ruby_version = ">= 2.5"
  end

  def mod name
    self.name = "card-mod-#{name}"
    self.version = decko_version
    self.metadata = { "card-mod" => name }
    self.files = Dir["{db,file,lib,public,set,config,vendor}/**/*", "README.md"]
    add_runtime_dependency "card", card_version
  end

  def depends_on_mod *modnames
    modnames.each do |modname|
      add_runtime_dependency "card-mod-#{modname}", decko_version
    end
  end

  private

  def bits
    @bits ||= decko_version.split(".").map(&:to_i)
  end

  def major
    bits[0]
  end

  def minor
    CARD_MINOR[major] + bits[1]
  end

  def point
    bits[2]
  end
end
