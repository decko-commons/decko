module Cardio
  class Mod
    class Sow
      # Writing the card representations to yaml files in mod directories
      module YamlDump
        # write yaml to file
        def dump hash
          File.write filename, hash.to_yaml
          puts "#{filename} now contains #{hash.size} items".green
        end

        # @return [String] -- MOD_DIR/data/ENVIRONMENT.yml
        def filename
          @filename ||= File.join mod_path, "#{@podtype}.yml"
        end

        # @return Path
        def mod_path
          Mod.dirs.subpaths("data")[@mod] ||
            raise(Card::Error::NotFound, "no data directory found for mod: #{@mod}")
        end
      end
    end
  end
end
