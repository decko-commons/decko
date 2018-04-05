# -*- encoding : utf-8 -*-

require_dependency "card/set"
require_dependency "card/set_pattern"
require_dependency "card/mod/loader/set_loader"
require_dependency "card/mod/loader/set_pattern_loader"

class Card
  module Mod
    # Card::Mod::Loader is used to load all part of a mod,
    # i.e. initializers, patterns, formats, chunks, layouts and sets

    # A Loader object provides tools for generating and loading sets and set patterns,
    # each of which are typically written using a Decko DSL.

    # The mods are given by a Mod::Dirs object.
    # SetLoader can use three different strategies to load the set modules.

    class Loader
      def initialize(load_strategy=:eval, mod_dirs=nil)
        mod_dirs ||= Mod.dirs
        klass = load_strategy_class load_strategy
        @load_strategy = klass.new mod_dirs, self
      end

      def load_strategy_class load_strategy
        case load_strategy
          when :tmp_files     then LoadStrategy::TmpFiles
          when :binding_magic then LoadStrategy::BindingMagic
          else                     LoadStrategy::Eval
        end
      end

      def load
        @load_strategy.load_modules
      end


      class << self
        attr_reader :module_type

        def load_mods
          SetPatternLoader.new.load
          load_formats
          SetLoader.new.load
          load_initializers
          # rescue
          # raise Card::Error, "unrescued error loading mods"
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

        def module_class_template
          const_get :Template
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
          Mod.dirs.each(:format) do |dir|
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
