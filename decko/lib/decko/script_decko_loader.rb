require "pathname"

require "cardio/script_loader"

module Decko
  module ScriptDeckoLoader
    extend Cardio::ScriptLoader::ClassMethods

    def self.script
      File.join("script", "decko")
    end
  end
end
