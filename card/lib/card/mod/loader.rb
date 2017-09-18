# -*- encoding : utf-8 -*-

require_dependency "card/set"
require_dependency "card/set_pattern"
require_relative "loader/module_loader/pattern_loader"
require_relative "loader/module_loader/set_loader"

class Card
  module Mod
    # Used to load all part of a mod,
    # i.e. initializers, patterns, formats, chunks, layouts and sets
    module Loader
      class << self
        def load_mods
          load_initializers
          pattern_loader.load
          load_formats
          set_loader.load
        end

        def load_chunks
          Mod.dirs.each(:chunk) do |dir|
            load_dir dir
          end
        end

        def load_layouts
          hash = {}
          Mod.dirs.each(:layout) do |dirname|
            Dir.foreach(dirname) do |filename|
              next if filename =~ /^\./
              layout_name = filename.gsub(/\.html$/, "")
              hash[layout_name] = File.read File.join(dirname, filename)
            end
          end
          hash
        end

        def set_loader
          @set_loader ||= ModuleLoader::SetLoader.new Mod.dirs
        end

        def pattern_loader
          @pattern_loader ||= Loader::ModuleLoader::PatternLoader.new Mod.dirs
        end

        def mod_dirs
          Mod.dirs
        end

        private

        def load_initializers
          Card.config.paths["mod/config/initializers"].existent.sort.each do |initializer|
            load initializer
          end
        end

        # {Card::Format}
        def load_formats
          # cheating on load issues now by putting all inherited-from formats in core mod.
          mod_dirs.each(:format) do |dir|
            load_dir dir
          end
        end

        # load all files in directory
        # @param dir [String] directory name
        def load_dir dir
          Dir["#{dir}/*.rb"].sort.each do |file|
            # puts Benchmark.measure("from #load_dir: rd: #{file}") {
            require_dependency file
            # }.format('%n: %t %r')
          end
        end
      end
    end
  end
end
