# -*- encoding : utf-8 -*-

class Card
  module Mod
    # Card::Mod::Loader is used to load all part of a mod,
    # i.e. initializers, patterns, formats, chunks, layouts and sets
    # cards are not accessible at this point

    # A Loader object provides tools for generating and loading sets and set patterns,
    # each of which are typically written using a Decko DSL.

    # The mods are given by a Mod::Dirs object.
    # SetLoader can use three different strategies to load the set modules.
    class Loader
      def initialize load_strategy: nil, mod_dirs: nil
        load_strategy ||= Cardio.config.load_strategy
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
          SetLoader.new.load
          Set.process_base_modules
          load_initializers
        end

        def reload_sets
          Set::Pattern.reset
          Set.reset_modules
          SetPatternLoader.new.load
          SetLoader.new(patterns: Set::Pattern.nonbase_loadable_codes).load
        end

        def module_class_template
          const_get :Template
        end

        # private

        def load_initializers
          Card.config.paths["mod/config/initializers"].existent.sort.each do |initializer|
            load initializer
          end
        end

        # load all files in directory
        # @param dir [String] directory name
        def load_dir dir
          Dir["#{dir}/*.rb"].sort.each do |file|
            # puts Benchmark.measure("from #load_dir: rd: #{file}") {
            # require file
            # "require" breaks the reloading in development env
            load file
            # }.format('%n: %t %r')
          end
        end
      end
    end
  end
end
