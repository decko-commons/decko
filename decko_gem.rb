# -*- encoding : utf-8 -*-
require_relative "card/lib/cardio/version"

# Helper methods for gem specs and gem-related tasks
class DeckoGem
  attr_reader :spec

  RAILS_VERSION = "~> 6.1.4".freeze
  # reduce digits after 6.2 (mimemagic issue)

  class << self
    def gem name, mod=false
      Gem::Specification.new do |spec|
        dg = DeckoGem.new spec
        dg.shared
        dg.non_shared name, mod
        yield spec, dg
      end
    end

    def mod name, &block
      gem name, true, &block
    end

    def decko_version
      Cardio::Version.release
    end

    def card_version
      Cardio::Version.card_release
    end
  end

  def initialize spec
    @spec = spec
  end

  def shared
    spec.authors = ["Ethan McCutchen", "Philipp Kühl", "Gerry Gleason"]
    spec.email = ["info@decko.org"]
    spec.homepage = "https://decko.org"
    spec.licenses = ["GPL-3.0"]
    spec.required_ruby_version = ">= 2.5"
    spec.version = decko_version
  end

  def non_shared name, is_mod
    if is_mod
      mod name
    else
      spec.name = name
      spec.metadata = standard_metadata
    end
  end

  def mod name
    spec.name = "card-mod-#{name}"
    spec.metadata = standard_metadata.merge "card-mod" => name,
                                            "card-mod-group" => "gem-defaults"
    spec.files = Dir[
      "{assets,config,data,db,file,init,lib,locales,public,set,vendor}/**/*", "README.md"
    ]
    spec.add_runtime_dependency "card", card_version
  end

  def standard_metadata
    {
      "source_code_uri" => "https://github.com/decko-commons/decko",
      "homepage_uri" => "https://decko.org",
      "bug_tracker_uri" => "https://github.com/decko-commons/decko/issues",
      "wiki_uri" => "https://decko.org",
      "documentation_url" => "http://docs.decko.org/"
    }
  end

  def depends_on *gems
    gems.each { |gem| spec.add_runtime_dependency(*[gem].flatten) }
  end

  def depends_on_mod *mods
    mods.each { |mod| spec.add_runtime_dependency "card-mod-#{mod}", decko_version }
  end

  def decko_version
    DeckoGem.decko_version
  end

  def card_version
    DeckoGem.card_version
  end

  def rails_version
    RAILS_VERSION
  end
end
