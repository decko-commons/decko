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

      def yaml
        Card::Auth.as_bot do
          Card[@name].to_yaml
        end
      end

      def filename
        File.join mod_path, "#{@env}.yml"
      end

      def dump
      end




      # @return Path
      def mod_path
        Mod.dirs.subpaths("data")[@mod]
      end
    end
  end
end
