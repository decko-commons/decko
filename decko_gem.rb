# -*- encoding : utf-8 -*-

# Helper methods for gem specs and gem-related tasks
module DeckoGem
  VERSION = File.open(File.expand_path("../card/VERSION", __FILE__)).read.chomp
  CARD_MINOR = { 0 => 90, 1 => 1000 }.freeze # can remove and hardcode after 1.0

  class << self
    def version
      VERSION
    end

    def card_version
      [1, minor, point].compact.map(&:to_s).join "."
    end

    def shared spec
      spec.authors = ["Ethan McCutchen", "Philipp Kühl", "Gerry Gleason"]
      spec.email = ["info@decko.org"]
      spec.homepage = "http://decko.org"
      spec.licenses = ["GPL-2.0", "GPL-3.0"]
      spec.required_ruby_version = ">= 2.5"
    end

    def mod spec, name
      spec.name = "card-mod-#{name}"
      spec.version = version
      spec.metadata = { "card-mod" => name }
      spec.add_runtime_dependency "card", card_version
      spec.files = Dir["{db,file,lib,public,set,config,vendor}/**/*", "README.md"]
    end

    def depends_on_mod spec, *modnames
      modnames.each do |modname|
        spec.add_runtime_dependency "card-mod-#{modname}", version
      end
    end

    private

    def bits
      @bits ||= version.split(".").map(&:to_i)
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
end
