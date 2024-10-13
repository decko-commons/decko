class Card
  class Cache
    # class methods for Card::Cache::reset_temp
    module SharedClass
      def stamp
        @stamp ||= Cardio.cache.fetch(stamp_key) { new_stamp }
      end

      # stamp generator
      def new_stamp
        Time.now.to_i.to_s(36) + rand(999).to_s(36)
      end

      def stamp_key
        "#{Cardio.database}-stamp"
      end

      def renew
        @stamp = nil
      end

      def reset
        @stamp = new_stamp
        Cardio.cache.write stamp_key, @stamp
      end
    end
  end
end
