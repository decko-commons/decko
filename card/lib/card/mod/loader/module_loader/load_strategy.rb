class Card
  module Mod
    # Shared code for the three different load strategies: Eval, TmpFiles and BindingMagic
    module Loader
      class ModuleLoader
        class LoadStrategy
          def initialize mod_dirs, module_type, module_template
            @mod_dirs = mod_dirs
            @module_type = module_type # :set or :set_pattern
            @module_template = module_template
          end

          private

          def each_file &block
            @mod_dirs.each @module_type do |base_dir|
              if @module_type == :set
                # I'm not sure if we really need this ordering by pattern for sets -pk
                Card::Set::Pattern.in_load_order.each do |pattern|
                  each_file_in_dir base_dir, pattern, &block
                end
              else
                each_file_in_dir base_dir, &block
              end
            end
          end

          def each_file_in_dir base_dir, subdir=nil
            pattern = File.join(*[base_dir, subdir, "**/*.rb"].compact)
            Dir.glob(pattern).each do |abs_path|
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
  end
end
