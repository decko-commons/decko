module Patches
  module ActiveJob
    # monkeypatch ActiveJob so that it can handle more types of arguments
    module Arguments
      CLASS_NAME_KEY = "_aj_class_name_key".freeze
      VALUE_KEY = "_aj_value_key".freeze

      private

      def serialize_argument argument
        case argument
        when Symbol, Time, DateTime
          { VALUE_KEY => argument.to_s, CLASS_NAME_KEY => argument.class.to_s }
        when ActionController::Parameters
          { VALUE_KEY => serialize_argument(argument.to_unsafe_h),
            CLASS_NAME_KEY => argument.class.to_s }
        else
          super
        end
      end

      # all custom serialized arguments become hashes
      # hence for deserializing we only have to check hashes
      def deserialize_hash serialized_hash
        return super unless serialized_hash[CLASS_NAME_KEY]
        value = serialized_hash[VALUE_KEY]
        case serialized_hash[CLASS_NAME_KEY]
        when "Symbol"
          value.to_sym
        when "Time", "DateTime"
          Object.const_get(serialized_hash[CLASS_NAME_KEY]).parse value
        when "ActionController::Parameters"
          # TODO: handle the permitted status
          ActionController::Parameters.new deserialize_hash(value)
        else
          value
        end
      end
    end
  end
end
