# Decko puts cards on the web
module Decko
  DECKO_GEM_ROOT = File.expand_path("..", __dir__)

  class << self
    delegate :application, :root, to: :Rails
    delegate :config, :paths, to: :application

    def gem_root
      DECKO_GEM_ROOT
    end
  end
end
