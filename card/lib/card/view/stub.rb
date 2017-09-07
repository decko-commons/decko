class Card
  class View
    # A "stub" is a placeholder for a card view.
    #
    # Cached views use stubs so that _nesting_ content can remained cached
    # even while _nested_ content changes. The nested content's place is held
    # by a stub.
    #
    # A stub must contain all the information necessary to produce the view as intended.
    #
    module Stub
      # @return [String]
      def stub
        "<card-view>#{stub_json}</card-view>"
      end

      # @return [String] the stub_hash as JSON
      def stub_json
        JSON.generate stub_hash
      end

      # @return [Hash]
      def stub_hash
        {
          cast: card.cast,
          options: normalized_options,
          mode: format.nest_mode
        }
      end

      def validate_stub!
        reject_foreign_options_in_stub!
        #reject_illegal_stub_values!
      end

      #def reject_illegal_stub_values!
      #  normalized_options.each do |key, value|
      #    next unless value =~ /\</
      #    raise invalid_stub + " has illegal value for #{key}: #{value}"
      #  end
      #end

      def invalid_stub
        "INVALID STUB: #{card.name}/#{ok_view}"
      end


      def reject_foreign_options_in_stub!
        return if foreign_normalized_options.empty?
        raise invalid_stub + " has foreign options: #{foreign_normalized_options}"
      end
    end
  end
end
