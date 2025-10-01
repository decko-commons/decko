module CarrierWave
  module CardMount
    # helper methods for mounted cards
    module Helper
      def read_uploader(*)
        read_attribute(*)
      end

      def write_uploader(*)
        write_attribute(*)
      end

      def reload *_args
        @_mounters = nil
        super
      end

      def serializable_hash opts=nil
        except = serializable_hash_config opts, :except
        only = serializable_hash_config opts, :only

        self.class.uploaders.each_with_object(super) do |(column, _uploader), hash|
          if add_column_to_serializable_hash? column.to_s, only, except
            hash[column.to_s] = _mounter(column).uploader.serializable_hash
          end
        end
      end

      private

      def serializable_hash_config opts, key
        opts&.dig(key) && Array.wrap(opts[:key]).map(&:to_s)
      end

      def add_column_to_serializable_hash? column, only, except
        if only
          only.include? column
        elsif except
          !except.include? column
        end
      end
    end
  end
end
