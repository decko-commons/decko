class Card
  module Env
    # serializing environment (eg for delayed jobs)
    module Serialization
      SERIALIZABLE_ATTRIBUTES = ::Set.new %i[
        main_name params ip ajax html host protocol salt
      ]

      # @param serialized_env [Hash]
      def with serialized_env
        tmp_env = serialize if @env
        @env ||= {}
        @env.update serialized_env
        yield
      ensure
        @env.update tmp_env if tmp_env
      end

      def serialize
        @env.select { |k, _v| SERIALIZABLE_ATTRIBUTES.include?(k) }
      end
    end
  end
end
