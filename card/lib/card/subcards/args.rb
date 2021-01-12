class Card
  class Subcards
    # Handling shared subcard args processing
    module Args
      def extract_subcard_args! args
        subcards = args.delete(:subcards) || {}
        extract_explicit_subfields subcards, args
        extract_implicit_subfields subcards, args

        # FIXME: the following should be handled before it gets this far
        subcards = subcards.to_unsafe_h if subcards.respond_to?(:to_unsafe_h)
        subcards
      end

      private

      def extract_explicit_subfields subcards, args
        return unless (subfields = args.delete :subfields)

        subfields.each_pair do |key, value|
          subcards[name.field(key)] = value
        end
      end

      def extract_implicit_subfields subcards, args
        args.keys.each do |key|
          subcards[key] = args.delete(key) if key.to_s =~ /^\+/
        end
      end
    end
  end
end
