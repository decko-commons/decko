class Card
  class View
    module Options
      # VooApi methods let developers use view options dynamically.
      module VooApi
        # There are two primary options hashes:

        # - @normalized_options are determined upon initialization and do not change
        # after that.
        # @return [Hash] options
        attr_reader :normalized_options

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
              live_options[option_key]
            end
          end

          def define_setter option_key
            define_method "#{option_key}=" do |value|
              live_options[option_key] = special_option_value(option_key, value) || value
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
          normalized_options.merge(view: requested_view).slice(*Options.slot_keys)
        end

        # def inherit key
        #   if live_options.key? key
        #     live_options[key]
        #   elsif (ancestor = next_ancestor)
        #     ancestor.inherit key
        #   end
        # end

        # ACCESSOR_HELPERS
        # methods that follow the normalize_#{key} pattern are called by accessors
        # (arguably that should be done during normalization!)

        def normalize_special_options! opts
          opts.each do |option_key, value|
            new_value = special_option_value option_key, value
            opts[option_key] = new_value if new_value
          end
        end

        def special_option_value option_key, value
          try "normalize_#{option_key}", value
        end

        def normalize_editor value
          value&.to_sym
        end

        def normalize_edit value
          value&.to_sym
        end

        def normalize_cache value
          value&.to_sym
        end

        def normalize_wrap value
          value = value.split(",").map(&:strip) if value.is_a? String
          Array.wrap(value).compact.flatten
        end

        protected

        # - @live_options are dynamic and can be altered by the "voo" API at any time.
        # Such alterations are NOT used in the stub of the current voo, but they
        # ARE inherited by children voos.
        #
        # @return [Hash]
        def live_options
          @live_options ||= process_live_options
        end

        private

        # option normalization includes standardizing options into a hash with
        # symbols as keys, managing standard view inheritance, and special
        # handling for main_views.
        def normalize_options
          @normalized_options = opts = options_to_hash @raw_options.clone
          normalize_special_options! opts
          @optional = opts.delete(:optional) || false
          add_implicit_options!
          inherit_options_from_parent!
          validate_options! opts
          opts
        end

        def add_implicit_options!
          @normalized_options[:view] = @raw_view
          @normalized_options[:main] = true if format.main?
          # opts[:context_names] = format.context_names
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
        def inherit_options_from_parent!
          return unless parent

          Options.heir_keys.each do |option_key|
            inherit_from_parent! option_key
          end
        end

        def inherit_from_parent! option_key
          return unless (parent_value = parent.live_options[option_key])

          @normalized_options[option_key] ||= parent_value
        end

        def process_live_options
          @live_options = normalized_options.clone
          process_main_nest_options
          process_before_view
          process_visibility
          return :hide if hide_requested_view? # bail to avoid unnecessary processing

          process_view_wrappers
          @live_options
        end

        # This method triggers the "before" blocks which can alter the @live_options
        # hash both directly and indirectly (via the voo API)
        def process_before_view
          format.before_view requested_view
        end

        # adds the wrappers assigned to ok_view in view definition
        def process_view_wrappers
          view_wrappers = format.view_setting(:wrap, ok_view)
          return unless view_wrappers.present?

          @live_options[:wrap] = Array.wrap(@live_options[:wrap])
          if view_wrappers.is_a? ::Hash
            view_wrappers.each_pair do |name, opts|
              @live_options[:wrap] << [name, opts]
            end
          else
            @live_options[:wrap] += Array.wrap(view_wrappers)
          end
        end

        # merge the options of the main nest into the @live_options
        # They are not processed in normalize_options so that
        # they're NOT locked in the stub.
        def process_main_nest_options
          @live_options.merge! format.main_nest_options if @live_options[:main_view]
        end

        def validate_options! opts
          return unless (foreign_opts = foreign_options_in opts)

          # TODO: this should raise a UserError if the options come directly from params
          # (eg, mycard?slot[badoption]=true should not be treated as a server error)
          raise Card::Error, "illegal view options: #{foreign_opts}"
        end

        # find non-standard option in Hash
        # @param opts [Hash] options hash
        # @return [Hash] options Hash
        def foreign_options_in opts
          foreign_opts = opts.reject { |k, _v| Options.all_keys.include? k }
          foreign_opts.empty? ? nil : foreign_opts
        end
      end
    end
  end
end
