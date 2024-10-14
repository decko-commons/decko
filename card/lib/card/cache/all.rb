class Card
  class Cache
    # cache-related instance methods available to all Cards
    module All
      def expire cache_type=nil
        return unless (cache_class = cache_class_from_type cache_type)

        expire_views
        expire_names cache_class
        expire_id cache_class
      end

      def view_cache_clean?
        !db_content_changed?
      end

      def ensure_view_cache_key cache_key
        return if view_cache_keys.include? cache_key

        view_cache_keys << cache_key
        shared_write_view_cache_keys
      end

      private

      def shared_read_view_cache_keys key_root=key
        Card.cache.shared&.read_attribute key_root, :view_cache_keys
      end

      def shared_write_view_cache_keys
        # puts "WRITE VIEW CACHE KEYS (#{name}): #{view_cache_keys}"
        Card.cache.shared&.write_attribute key, :view_cache_keys, view_cache_keys
      end

      def cache_class_from_type cache_type
        cache_type ? Card.cache.send(cache_type) : Card.cache
      end

      def view_cache_keys
        @view_cache_keys ||= shared_read_view_cache_keys(key) || []
      end

      def expire_names cache
        each_key_version do |key_version|
          expire_name key_version, cache
        end
      end

      def expire_name name_version, cache
        return unless name_version.present?

        key_version = name_version.to_name.key
        return unless key_version.present?

        cache.delete key_version
      end

      def expire_views
        each_key_version do |key|
          # puts "EXPIRE VIEW CACHE (#{name}): #{view_cache_keys}"
          view_keys = shared_read_view_cache_keys key
          next unless view_keys.present?

          expire_view_cache_keys view_keys
        end
        @view_cache_keys = []
      end

      def expire_id cache
        return unless id.present?

        cache.delete "~#{id}"
      end

      def expire_view_cache_keys view_keys
        Array.wrap(view_keys).each do |view_key|
          Card::View.cache.delete view_key
        end
      end

      def each_key_version
        [name, name_before_act].uniq.compact.each do |name_version|
          yield name_version.to_name.key
        end
      end
    end
  end
end
