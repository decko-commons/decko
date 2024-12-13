module CarrierWave
  module CardMount
    # helper methods for mounted cards
    module Helper
      def read_uploader *args
        read_attribute *args
      end

      def write_uploader *args
        write_attribute *args
      end

      def serializable_hash(opts=nil)
        except = opts&.dig(:except) && Array.wrap(opts[:except]).map(&:to_s)
        only = opts&.dig(:only) && Array.wrap(opts[:only]).map(&:to_s)

        self.class.uploaders.each_with_object(super(opts)) do |(column, uploader), hash|
          if (!only && !except) ||
            (only && only.include?(column.to_s)) ||
            (!only && except && !except.include?(column.to_s))
            hash[column.to_s] = _mounter(column).uploader.serializable_hash
          end
        end
      end

      def reload(*)
        @_mounters = nil
        super
      end
    end
  end
end
