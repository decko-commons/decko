class Card
  class View
    module Cache
      # A "stub" is a placeholder for a card view.
      #
      # Cached views use stubs so that _nesting_ content can remained cached
      # even while _nested_ content changes. The nested content's place is held
      # by a stub.
      #
      # A stub must contain all the information necessary to produce the view as intended.
      module Stub
        private

        # @return [String]
        def stub
          "(StUb#{stub_hash.to_json}sTuB)".html_safe
        end

        def bin_to_hex string
          string.unpack("H*").first
        end

        # @return [Hash]
        def stub_hash
          { cast: stub_cast,
            view_opts: normalized_options.merge(normalized_visibility_options),
            format_opts: { nest_mode: format.nest_mode,
                           override: root?,
                           context_names: format.context_names } }
          # nest mode handling:
          #
          # Typically modes override views on nests, but stubs create non-standard nests.
          # Mode-based view overrides should NOT apply to standard render calls that have
          # been replaced with stubs - only to standard nest calls. The override value
          # is used to retain this distinction.
        end

        def stub_cast
          cast = card.cast
          cast.delete :content if cast[:content].nil?
          cast
        end
      end
    end
  end
end
