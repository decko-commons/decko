class Card
  module Mod
    module Loader
      class PatternLoader
        class TmpFiles < Card::Mod::LoadStrategy::TmpFiles
          private

          def load_tmp_files
            load_dir tmp_dir
          end

          def generate_tmp_files
            prepare_tmp_dir "tmp/set_pattern"
            seq = 100
            each_file do |abs_path, const_parts|
              pattern = const_parts.first
              to_file = "#{tmp_dir}/#{seq}-#{pattern}.rb"
              write_tmp_file abs_path, to_file, const_parts
              seq += 1
            end
          end

          def tmp_dir
            Card.paths["tmp/set_pattern"].first
          end
        end
      end
    end
  end
end
