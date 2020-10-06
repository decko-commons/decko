class Card
  module Mod
    class LoadStrategy
      # LoadStrategy for mod modules. It writes the code to tmp files
      # and then loads the tmp files. (deprecated)
      class TmpFiles < LoadStrategy
        def load_modules
          generate_tmp_files if rewrite_tmp_files?
          load_tmp_files
        end

        def clean_comments?
          true
        end

        private

        def prepare_tmp_dir path
          return unless rewrite_tmp_files?

          p = Cardio.paths[path]
          FileUtils.rm_rf p.first, secure: true if p.existent.first
          Dir.mkdir p.first
        end

        def rewrite_tmp_files?
          if defined?(@rewrite)
            @rewrite
          else
            @rewrite = !(Rails.env.production? &&
              Cardio.paths["tmp/set"].existent.first)
          end
        end

        def write_tmp_file from_file, to_file, const_parts
          FileUtils.mkdir_p File.dirname(to_file)
          mt = module_template.new const_parts, from_file, self
          File.write to_file, mt.to_s
        end
      end
    end
  end
end
