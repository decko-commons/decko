class Card
  module Mod
    # Shared code for the three different load strategies: Eval, TmpFiles and BindingMagic
    class LoadStrategy
      def self.klass symbol
        case symbol
        when :tmp_files     then TmpFiles
        when :binding_magic then BindingMagic
        else                     Eval
        end
      end

      def initialize mod_dirs, loader
        @mod_dirs = mod_dirs
        @loader = loader
      end

      def clean_comments?
        false
      end

      private

      def module_type
        @loader.class.module_type
      end

      def module_template
        @loader.class.module_class_template
      end

      def each_file &block
        if module_type == :set
          each_set_file(&block)
        else
          each_mod_dir module_type do |base_dir|
            each_file_in_dir base_dir, &block
          end
        end
      end

      def each_set_file &block
        each_mod_dir :set do |base_dir|
          @loader.patterns.each do |pattern|
            each_file_in_dir base_dir, pattern.to_s, &block
          end
        end
      end

      def each_mod_dir module_type
        @mod_dirs.each module_type do |base_dir|
          yield base_dir
        end
      end

      def each_file_in_dir base_dir, subdir=nil
        pattern = File.join(*[base_dir, subdir, "**/*.rb"].compact)
        Dir.glob(pattern).sort.each do |abs_path|
          rel_path = abs_path.sub("#{base_dir}/", "")
          const_parts = parts_from_path rel_path
          yield abs_path, const_parts
        end
      end

      def parts_from_path path
        # remove file extension and number prefixes
        parts = path.gsub(/\.rb/, "").gsub(%r{(?<=\A|/)\d+_}, "").split(File::SEPARATOR)
        parts.map(&:camelize)
      end
    end
  end
end
