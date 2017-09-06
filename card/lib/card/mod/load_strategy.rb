class Card
  module Mod
    class LoadStrategy
      def initialize mod_dirs, module_type, module_template
        @mod_dirs = mod_dirs
        @module_type = module_type # :set or :set_pattern
        @module_template = module_template
      end

      private

      def each_file &block
        @mod_dirs.each @module_type do |base_dir|
          each_file_in_dir base_dir, &block
        end
      end

      def each_file_in_dir base_dir
        Dir.glob("#{base_dir}/**/*.rb").each do |abs_path|
          rel_path = abs_path.sub("#{base_dir}/", "")
          const_parts = parts_from_path rel_path
          yield abs_path, const_parts
        end
      end

      def parts_from_path path
        # remove file extension and number prefixes
        parts = path.gsub(/\.rb/, "").gsub(%r{(?<=\A|/)\d+_}, "").split(File::SEPARATOR)
        parts.map &:camelize
      end
    end
  end
end
