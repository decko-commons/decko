# -*- encoding : utf-8 -*-

module Cardio
  class Mod
    # Cardio::Mod::Loader is used to load all part of a mod,
    # i.e. initializers, patterns, formats, chunks, layouts and sets
    # cards are not accessible at this point

    # A Loader object provides tools for generating and loading sets and set patterns,
    # each of which are typically written using a Decko DSL.

    # The mods are given by a Mod::Dirs object.
    # SetLoader can use three different strategies to load the set modules.
    class Loader
      class << self
        def load_mods
          SetPatternLoader.new.load
          SetLoader.new.load
          Card::Set.process_base_modules
          load_initializers
        end

        def reload_sets
          Card::Set::Pattern.reset
          Card::Set.reset
          SetPatternLoader.new.load
          SetLoader.new(no_all: true).load
        end

        def load_initializers
          Cardio.config.paths["late/initializers"].existent.each do |init|
            load init
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

      attr_reader :mod_dirs

      def initialize load_strategy: nil, mod_dirs: nil
        load_strategy ||= Cardio.config.load_strategy
        @mod_dirs = mod_dirs || Mod.dirs
        @load_strategy = load_strategy_class(load_strategy).new self
      end

      def load
        @load_strategy.load_modules
      end

      def parts_from_path path
        # remove file extension and number prefixes
        parts = path.gsub(/\.rb$/, "").gsub(%r{(?<=\A|/)\d+_}, "").split(File::SEPARATOR)
        parts.map(&:camelize)
      end

      private

      def each_mod_dir module_type, &block
        @mod_dirs.each module_type, &block
      end

      def each_file_in_dir base_dir, subdir=nil
        pattern = File.join(*[base_dir, subdir, "**/*.rb"].compact)
        Dir.glob(pattern).sort.each do |abs_path|
          rel_path = abs_path.sub("#{base_dir}/", "")
          const_parts = parts_from_path rel_path
          yield abs_path, const_parts
        end
      end
    end
  end
end
