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

      class << self
        def escape stub_json
          stub_json.gsub "(", "_OParEN_"
        end

        def unescape stub_json
          stub_json.gsub "_OParEN_", "("
        end
      end

      # @return [String]
      def stub
        "(stub)#{Stub.escape stub_json}(/stub)".html_safe
      end

      # @return [String] the stub_hash as JSON
      def stub_json
        JSON.generate stub_hash
      end

      # @return [Hash]
      def stub_hash
        with_override cast: card.cast,
                      view_opts: normalized_options,
                      format_opts: { nest_mode: format.nest_mode,
                                     override: root? }
      end

      # handle nest_mode in stub
      # @return [Hash]
      def with_override hash
        # typically modes only override views on nests, but stubs create non-standard nests
        # mode-based view overrides should NOT apply to standard render calls that have
        # been replaced with stubs - only to standard nest calls. therefore modes are not
        # stored in non-standard nest stubs
        hash
      end

      def validate_stub!
        # reject_illegal_stub_values!
      end

      # def reject_illegal_stub_values!
      #   normalized_options.each do |key, value|
      #     next unless value =~ /\</
      #     raise invalid_stub + " has illegal value for #{key}: #{value}"
      #   end
      # end

      def invalid_stub
        "INVALID STUB: #{card.name}/#{ok_view}"
      end
    end
  end
end
