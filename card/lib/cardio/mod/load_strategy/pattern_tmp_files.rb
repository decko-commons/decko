class Card
  module Mod
    class LoadStrategy
      # The {TmpFiles} load strategy version for set pattern modules/
      class PatternTmpFiles < TmpFiles
        private

        def generate_tmp_files
          prepare_tmp_dir "tmp/set_pattern"
          seq = 100
          each_file do |abs_path, const_parts|
            pattern = const_parts.first.underscore
            to_file = "#{tmp_dir}/#{seq}-#{pattern}.rb"
            write_tmp_file abs_path, to_file, const_parts
            seq += 1
          end
        end

        def load_tmp_files
          Loader.load_dir tmp_dir
        end

        def tmp_dir
          Cardio.paths["tmp/set_pattern"].first
        end
      end
    end
  end
end
