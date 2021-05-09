module Patches
  module ActiveJob
    # Monkeypatch ActiveJob so that it can handle more types of arguments.
    # Add Integer hash keys and Symbol, Time, DateTime hash values and
    # ActionController::Parameters
    module Arguments
      CLASS_NAME_KEY = "_aj_class_name_key".freeze
      VALUE_KEY = "_aj_value_key".freeze
      INTEGER_KEYS_KEY = "_aj_integer_keys".freeze

      private

      def serialize_argument argument
        case argument
        when Symbol, Time, DateTime
          { VALUE_KEY => argument.to_s, CLASS_NAME_KEY => argument.class.to_s }
        when ActionController::Parameters
          { VALUE_KEY => serialize_argument(argument.to_unsafe_h),
            CLASS_NAME_KEY => argument.class.to_s }
        when Hash
          integer_keys = argument.each_key.grep(Integer).map(&:to_s)
          result = super
          result[INTEGER_KEYS_KEY] = integer_keys
          result
        else
          super
        end
      end

      def serialize_hash_key key
        case key
        when Integer
          key.to_s
        else
          super
        end
      end

      # all custom serialized arguments become hashes
      # hence for deserializing we only have to check hashes
      def deserialize_hash serialized_hash
        if serialized_hash[CLASS_NAME_KEY]
          deserialize_object serialized_hash
        else
          handle_integer_keys super
        end
      end

      def handle_integer_keys result
        if (integer_keys = result.delete(INTEGER_KEYS_KEY) && integer_keys.present?)
          result = transform_integer_keys(result, integer_keys)
        end
        result
      end

      def deserialize_object hash
        value = hash[VALUE_KEY]
        class_name = hash[CLASS_NAME_KEY]
        case class_name
        when "Symbol"
          value.to_sym
        when "Time", "DateTime"
          Object.const_get(class_name).parse value
        when "ActionController::Parameters"
          # TODO: handle the permitted status
          ActionController::Parameters.new deserialize_hash(value)
        else
          value
        end
      end

      def transform_integer_keys hash, integer_keys
        hash.transform_keys do |key|
          if integer_keys.include?(key)
            key.to_i
          else
            key
          end
        end
      end
    end
  end
end
