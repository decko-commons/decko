module Cardio
  class Mod
    # export data to data directory of mods
    # (list of card attributes)
    # https://docs.google.com/document/d/13K_ynFwfpHwc3t5gnLeAkZJZHco1wK063nJNYwU8qfc/edit#
    class OutData
      def initialize mod: nil, name:, env: nil
        @mod = mod
        @name = name
        @env = env || :production
      end

      # @return array of
      def items
        [Card[@name].format(:yaml).render(:export)]
      end

      def filename
        File.join mod_path, "#{@env}.yml"
      end

      def out
        @mod ? dump : puts(items)
      end

      def dump
        File.open filename, "r+" do |file|
          raw = file.read
          puts "OLD/raw: #{raw}"
          old_items = YAML.safe_load raw
          file.write merge(old_items).to_yaml
        end
      end

      private

      def merge old_items
        puts "OLD: #{old_items}"
        puts "NEW: #{items}"
        items + ["woot"]
      end

      # @return Path
      def mod_path
        Mod.dirs.subpaths("data")[@mod]
      end
    end
  end
end
