class Card
  class View
    module Options
      # The methods of the VooApi module allow developers
      # to read and write options dynamically.
      module VooApi
        # There are two primary options hashes:

        # - @normalized_options are determined upon initialization and do not change
        # after that.
        # @return [Hash] options
        attr_reader :normalized_options

        # - @live_options are dynamic and can be altered by the "voo" API at any time.
        # Such alterations are
        #   NOT used in stubs
        # @return [Hash]
        def live_options
          @live_options ||= process_live_options
        end

        class << self
          def included base
            # Developers can also set most options directly via accessors,
            # eg voo.title = "King"
            # :view, :show, and :hide have non-standard access (see #accessible_keys)

            base.accessible_keys.each do |option_key|
              define_getter option_key unless option_key == :items
              define_setter option_key
            end
          end

          def define_getter option_key
            define_method option_key do
              norm_method = "normalize_#{option_key}"
              value = live_options[option_key]
              try(norm_method, value) || value
            end
          end

          def define_setter option_key
            define_method "#{option_key}=" do |value|
              live_options[option_key] = value
            end
          end
        end

        # "items", the option used to configure views of each of a list of cards, is
        # currently the only Hash option (thus this accessor override)
        # @return [Hash]
        def items
          live_options[:items] ||= {}
        end

        # options to be used in data attributes of card slots (normalized options
        # with standard keys)
        # FIXME: what we really want is options as they were when render was called.
        # normalized is wrong because it can get changed before render. live is wrong
        # because they can get changed after.  current solution is a compromise.
        # @return [Hash]
        def slot_options
          normalized_options.merge(view: requested_view).select do |k, _v|
            Options.all_keys.include? k
          end
        end

        def closest_live_option key
          if live_options.key? key
            live_options[key]
          elsif (ancestor = next_ancestor)
            ancestor.closest_live_option key
          end
        end

        # ACCESSOR_HELPERS
        # methods that follow the normalize_#{key} pattern are called by accessors
        # (arguably that should be done during normalization!)

        def normalize_editor value
          value&.to_sym
        end

        def normalize_cache value
          value&.to_sym
        end

        private

        # option normalization includes standardizing options into a hash with
        # symbols as keys, managing standard view inheritance, and special
        # handling for main_views.
        def normalize_options
          @normalized_options = opts = options_to_hash @raw_options.clone
          opts[:view] = @raw_view
          inherit_from_parent if parent
          opts[:main] = true if format.main?
          @optional = opts.delete(:optional) || false
          opts
        end

        # typically options are already a hash.  this also handles an array of
        # hashes and nil.
        def options_to_hash opts
          case opts
          when ActionController::Parameters
            opts.to_unsafe_h.deep_symbolize_keys
          when Hash  then opts.deep_symbolize_keys!
          when Array then opts[0].merge(opts[1]).deep_symbolize_keys!
          when nil   then {}
          else raise Card::Error, "bad view options: #{opts}"
          end
        end

        # standard inheritance from parent view object
        def inherit_from_parent
          Options.heir_keys.each do |key|
            parent_value = parent.live_options[key]
            normalized_options[key] ||= parent_value if parent_value
          end
        end

        def process_live_options
          @live_options = normalized_options.clone
          if @live_options[:main_view]
            @live_options.merge! format.main_nest_options
          end
          # main_nest_options are not processed in normalize_options so that
          # they're NOT locked in the stub.
          process_default_options
          process_visibility_options
          @live_options
        end

        # This method triggers the default_X_args methods which can alter the
        # @live_options hash both directly and indirectly (via the voo API)
        def process_default_options
          format.view_options_with_defaults requested_view, live_options
        end

        # "foreign" options are non-standard options.  They're allowed, but they
        # prevent independent caching (and thus stubbing)

        # non-standard options that are found in normalized_options
        # @return [Hash] options Hash
        def foreign_normalized_options
          @foreign_normalize_options ||= foreign_options_in normalized_options
        end

        # non-standard options that are found in live_options
        # @return [Hash] options Hash
        def foreign_live_options
          foreign_options_in live_options
        end

        # find non-standard option in Hash
        # @param opts [Hash] options hash
        # @return [Hash] options Hash
        def foreign_options_in opts
          opts.reject { |k, _v| Options.all_keys.include? k }
        end
      end
    end
  end
end
