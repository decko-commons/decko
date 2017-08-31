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
        return if foreign_normalized_options.empty?
        raise "INVALID STUB: #{card.name}/#{ok_view}" \
              " has foreign options: #{foreign_normalized_options}"
      end
    end
  end
end
