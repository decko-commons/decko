class Card
  class View
    # API to change css classes in other places
    module Classy
      # Add additional css classes to a css class
      #
      # Example
      #   class_up "card-slot", "card-dark text-muted"
      #
      #   If a view later adds the css "card-slot" to a html tag with
      #
      #     classy("card-slot")
      #
      #   then all additional css classes will be added.
      #
      # The scope when these additional classes apply can be restricted
      # @param klass [String, Symbol] the css class to be enriched with additional classes
      # @param classier [String, Array<String>] additional css classes
      # @param scope [Symbol]
      #    :view        only in the same view
      #    :subviews    the same and all subviews; not in nests or where its nested
      #    :format      all views, sub and parent views; not in nests or where its nested
      #    :nests       the same as :format but also in nests
      #    :single_use  the same as :nests but is removed after the first use
      #    :global      always everywhere
      def class_up klass, classier, scope=:subviews
        klass = klass.to_s

        storage_voo(scope).add_extra_classes klass, classier, scope
      end

      def class_down klass, classier
        remove_extra_classes klass, classier, :private
      end

      def with_class_up klass, classier, scope=:subviews
        class_up klass, classier, scope
        yield
      ensure
        class_down klass, classier
      end

      # don't use in the given block the additional class that
      # was added to `klass`
      def without_upped_class klass
        tmp_class = class_list.delete klass
        result = yield tmp_class
        class_list[klass] = tmp_class
        result
      end

      def classy *classes
        classes = Array.wrap(classes).flatten
        [classes, extra_classes(classes)].flatten.compact.join " "
      end

      def add_extra_classes key, classier, scope
        type = class_list_type scope

        class_list(type)[key] =
          [class_list(type)[key], classier].flatten.compact.join(" ")
      end

      # remove classes everywhere where they are visible for the given scope
      def remove_extra_classes klass, classier, type
        # TODO: scope handling
        # Method is not used and maybe no longer necessary with the scope feature
        # for class_up.

        # It's no longer sufficient to remove only public classes for ancestors.
        # Needs an approach similar to extra_classes with the "space" argument
        next_ancestor&.remove_extra_classes klass, classier, :public

        cl = class_list type
        return unless cl[klass]

        if cl[klass] == classier
          cl.delete klass
        else
          cl[klass].gsub!(/#{classier}\s?/, "")
        end
      end

      def extra_classes klass
        klass = klass.first if klass.is_a?(Array)
        klass = klass.to_s

        deep_extra_classes klass, :self
      end

      # recurse through voos and formats to find all extra classes
      # @param space [:self, :self_format, :ancestor_format]
      def deep_extra_classes klass, space
        [self_extra_classes(klass, space),
         ancestor_extra_classes(klass, space)].flatten.compact
      end

      private

      def storage_voo scope
        # When we climb up the voo tree and cross a nest boundary then we can jump only
        # to the root voo of the parent format. Hence we have to add classes to the root
        # if we want them to be found by nests.
        case scope
        when :view, :subviews             then self
        when :format, :nests, :single_use then root
        when :global                      then deep_root
        else
          raise ArgumentError, "invalid class_up scope: #{scope}"
        end
      end

      def self_extra_classes klass, space
        classes = ok_types(space).map { |ot| class_list(ot)[klass] }
        return classes unless class_list(:single_use)&.key? klass

        [classes, class_list(:single_use).delete(klass)]
      end

      def ancestor_extra_classes klass, space
        if parent
          parent_space = space == :self ? :self_format : :ancestor_format
          parent.deep_extra_classes(klass, parent_space)
        else
          next_format_ancestor&.deep_extra_classes(klass, :ancestor_format)
        end
      end

      def ok_types space
        case space
        when :ancestor_format then [:public]
        when :self_format     then %i[public format_private]
        when :self            then %i[public format_private private]
        end
      end

      def class_list type=:private
        case type
        when :private, :format_private, :public, :single_use
          @class_list ||= {}
          @class_list[type] ||= {}
        else
          raise ArgumentError, "#{type} not a valid class list"
        end
      end

      # Translates scopes to the privacy types used to manage the class lists.
      # A #classy calls looks in the following class_lists:
      #    private - only in the same voo
      #    format_private - the same voo and all parent voos in the same format
      #    public - in all voos in all parent formats
      def class_list_type scope
        case scope
        when :view
          :private
        when :format, :subviews
          :format_private
        when :nests, :global
          :public
        when :single_use
          :single_use
        else
          raise ArgumentError, "invalid class_up scope: #{scope}"
        end
      end
    end
  end
end
