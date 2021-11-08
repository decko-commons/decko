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

      # @return [Array <Hash>]
      def items
        @items ||= [Card[@name].format(:yaml).render(:export)]
      end

      # @return [String] -- MOD_DIR/data/ENVIRONMENT.yml
      def filename
        @filename ||= File.join mod_path, "#{@env}.yml"
      end

      # if output mod given,
      def out
        @mod ? dump : puts(items.to_yaml.yellow)
        :success
      rescue Card::Error::DataContextError => e
        Rails.logger.info "Could not output data:\n  #{e.message}"
        e.message
      end

      # write yaml to file
      def dump
        hash = output_hash
        File.write filename, hash.to_yaml
        puts "#{filename} now contains #{hash.size} items".green
      end

      private

      def output_hash
        if target.present?
          merge_data
          target
        else
          items
        end
      end

      def merge_data
        items.each do |item|
          if (index = target_index item)
            target[index] = item
          else
            target << item
          end
        end
      end

      def target_index new_item
        target.find_index do |target_item|
          new_code = new_item[:codename]
          (new_code.present? && new_code == target_item[:codename]) ||
            target_item[:name].to_name == new_item[:name].to_name
        end
      end

      def target
        @target ||= old_data
      end

      def old_data
        return nil unless File.exist? filename

        YAML.safe_load File.read(filename), [Symbol]
      end



      # @return Path
      def mod_path
        Mod.dirs.subpaths("data")[@mod] ||
          raise(Card::Error::DataContextError, "no data directory found for mod: #{@mod}")
      end
    end
  end
end
