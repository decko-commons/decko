module Decko
  DECKO_GEM_ROOT = File.expand_path("..", __dir__)

  class << self
    def root
      Rails.root
    end

    def application
      Rails.application
    end

    def config
      application.config
    end

    def paths
      application.paths
    end

    def gem_root
      DECKO_GEM_ROOT
    end
  end
end
