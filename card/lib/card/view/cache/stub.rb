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
        class << self
          def escape stub_json
            stub_json.gsub "(", "_OParEN_"
          end

          def unescape stub_json
            stub_json.gsub "_OParEN_", "("
          end

          # FIXME: escaping and unescaping stubs should not be necessary
          # It's used to avoid problems with altered views, but altering views is
          # unsafe and should be eliminated.  See {Card::View::Cache}.
        end

        private

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
          { cast: card.cast,
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
      end
    end
  end
end
