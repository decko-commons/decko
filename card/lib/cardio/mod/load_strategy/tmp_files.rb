module Cardio
  class Mod
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

          p = Card.paths[path]
          FileUtils.rm_rf p.first, secure: true if p.existent.first
          FileUtils.mkdir_p p.first
        end

        def rewrite_tmp_files?
          return @rewrite if defined? @rewrite

          @rewrite = !(Rails.env.production? && Card.paths["tmp/set"].existent.first)
        end

        def write_tmp_file from_file, to_file, const_parts
          FileUtils.mkdir_p File.dirname(to_file)
          mt = template_class.new const_parts, from_file, self
          File.write to_file, mt.to_s
        end
      end
    end
  end
end
