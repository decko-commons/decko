class Card
  module Mod
    class LoadStrategy
      # The {TmpFiles} load strategy version for set modules
      class SetTmpFiles < LoadStrategy::TmpFiles
        private

        def generate_tmp_files
          return unless prepare_tmp_dir "tmp/set"

          @mod_dirs.each_with_tmp(:set) do |mod_dir, mod_tmp_dir|
            Dir.mkdir mod_tmp_dir
            Dir.glob("#{mod_dir}/**/*.rb").each do |abs_path|
              rel_path = abs_path.sub "#{mod_dir}/", ""
              tmp_filename = File.join mod_tmp_dir, rel_path
              const_parts = parts_from_path rel_path
              # puts "write_tmp_file #{abs_path}, #{tmp_filename}, #{const_parts}"
              write_tmp_file abs_path, tmp_filename, const_parts
            end
          end
        end

        def load_tmp_files
          @mod_dirs.each_tmp(:set) do |set_tmp_dir|
            Card::Set::Pattern.loadable_codes.each do |pattern|
              pattern_dir = "#{set_tmp_dir}/#{pattern}"
              Loader.load_dir "#{pattern_dir}/**" if Dir.exist? pattern_dir
            end
          end
        end
      end
    end
  end
end
