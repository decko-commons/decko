class Card
  # handle card-related uri paths
  class Path
    cattr_accessor :cast_params
    self.cast_params = { slot: { hide: :array, show: :array, wrap: :array } }.freeze

    # normalizes certain path opts to specified data types
    module CastParams
      private

      def cast_path_hash hash, cast_hash=nil
        return hash unless hash.is_a? Hash

        cast_each_path_hash hash, (cast_hash || self.class.cast_params)
        hash
      end

      def cast_each_path_hash hash, cast_hash
        hash.each do |key, value|
          next unless (cast_to = cast_hash[key])

          hash[key] = cast_path_value value, cast_to
        end
      end

      def cast_path_value value, cast_to
        if cast_to.is_a? Hash
          cast_path_hash value, cast_to
        else
          send "cast_path_value_as_#{cast_to}", value
        end
      end

      def cast_path_value_as_array value
        Array.wrap value
      end
    end
  end
end
