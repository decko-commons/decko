# -*- encoding : utf-8 -*-

class Card
  module Set
    #  Whenever a Format object is instantiated for a card, it
    #  includes all views associated with BOTH (a) sets of which the card is a
    #  member and (b) the current format or its ancestors.  More on defining
    #  views below.
    #
    # View definitions
    #
    #   When you declare:
    #     view :view_name do
    #       #...your code here
    #     end
    #
    #   Methods are defined on the format
    #
    #   The external api with checks:
    #     render(:viewname, args)
    #
    module Format
      require_dependency "card/set/format/haml_views"

      def format *format_names, &block
        format_names.compact!
        if format_names.empty?
          format_names = [:base]
        elsif format_names.first == :all
          format_names =
            Card::Format.registered.reject { |f| Card::Format.aliases[f] }
        end
        format_names.each do |f|
          define_on_format f, &block
        end
      end

      def view *args, &block
        format { view(*args, &block) }
      end

      def before view, &block
        format { before view, &block }
      end

      def define_on_format format_name=:base, &block
        # format class name, eg. HtmlFormat
        klass = Card::Format.format_class_name format_name

        # called on current set module, eg Card::Set::Type::Pointer
        mod = const_get_or_set klass do
          # yielding set format module, eg Card::Set::Type::Pointer::HtmlFormat
          m = Module.new
          register_set_format Card::Format.class_from_name(klass), m
          m.extend Card::Set::AbstractFormat
          m
        end
        mod.class_eval(&block)
      end

      def register_set_format format_class, mod
        if all_set?
          all_set_format_mod! format_class, mod
        else
          format_type = abstract_set? ? :abstract_format : :nonbase_format
          # ready to include dynamically in set members' format singletons
          format_hash = modules[format_type][format_class] ||= {}
          format_hash[shortname] ||= []
          format_hash[shortname] << mod
        end
      end

      # make mod ready to include in base (non-set-specific) format classes
      def all_set_format_mod! format_class, mod
        modules[:base_format][format_class] ||= []
        modules[:base_format][format_class] << mod
      end

      # All Format modules are extended with this module in order to support
      # the basic format API (ok, view definitions.  It's just view
      # definitions.)
      # No longer just view definitions. Also basket definitions now.
      module AbstractFormat
        include Set::Basket
        include Set::Format::HamlViews

        mattr_accessor :views
        self.views = Hash.new { |h, k| h[k] = {} }

        def before view, &block
          define_method "_before_#{view}", &block
        end

        def view view, *args, &block
          #view = view.to_viewname.key.to_sym
          interpret_view_opts view, args[0] if block_given?
          view_method_block = view_block(view, args, &block)
          if async_view? args
            # This case makes only sense for HtmlFormat
            # but I don't see an easy way to override class methods for a specific
            # format. All formats are extended with this general module. So
            # a HtmlFormat.view method would be overridden by AbstractFormat.view
            # We need something like AbstractHtmlFormat for that.
            define_async_view_method view, &view_method_block
          else
            define_standard_view_method view, &view_method_block
          end
        end

        def define_standard_view_method view, &block
          views[self][view] = block
          define_method "_view_#{view}", &block
        end

        def define_async_view_method view, &block
          view_content = "#{view}_async_content"
          define_standard_view_method view_content, &block
          define_standard_view_method view do
            %(<card-view-placeholder data-url="#{path view: view_content}" />)
          end
        end

        def interpret_view_opts view, opts
          return unless opts.present?
          Card::Format.interpret_view_opts view, opts
          extract_view_cache_rules view, opts.delete(:cache)
        end

        def extract_view_cache_rules view, cache_rule
          return unless cache_rule
          methodname = Card::Format.view_cache_setting_method view
          define_method(methodname) { cache_rule }
        end

        def view_block view, args, &block
          return haml_view_block(view, wrap_with_slot?(args), &block) if haml_view?(args)
          block_given? ? block : lookup_alias_block(view, args)
        end

        def haml_view? args
          args.first.is_a?(Hash) && args.first[:template] == :haml
        end

        def wrap_with_slot? args
          args.first.is_a?(Hash) && args.first[:slot]
        end

        def async_view? args
          args.first.is_a?(Hash) && args.first[:async]
        end

        def lookup_alias_block view, args
          opts = args[0].is_a?(Hash) ? args.shift : { view: args.shift }
          opts[:mod] ||= self
          opts[:view] ||= view
          views[opts[:mod]][opts[:view]] || begin
            raise "cannot find #{opts[:view]} view in #{opts[:mod]}; " \
                  "failed to alias #{view} in #{self}"
          end
        end

        def source_location
          set_module.source_location
        end

        # remove the format part of the module name
        def set_module
          Card.const_get name.split("::")[0..-2].join("::")
        end
      end
    end
  end
end
