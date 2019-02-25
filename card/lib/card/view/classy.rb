class Card
  class View
    # Classy home for classes and klasses
    module Classy
      # @param scope [:nested, :global, :parent_nested, :self]
      def class_up klass, classier, force = true, scope = :nested
        key = klass.to_s
        return if !force && extra_classes(key).present?

        subject =
          case scope
          when :self, :nested then self
          when :parent_nested then (next_ancestor || self)
          when :global        then root
          end

        subject.add_extra_classes klass, classier, class_list_type(scope)
      end

      def class_down klass, classier
        remove_extra_classes klass, classier, :private
      end

      def with_class_up klass, classier, force = false
        class_up klass, classier, force
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

      def add_extra_classes key, classier, type
        class_list(type)[key] = [class_list(type)[key], classier].compact.join(" ")
      end

      def remove_extra_classes klass, classier, type
        next_ancestor&.remove_extra_classes klass, classier, :public

        cl = class_list type
        return unless cl[klass]

        if cl[klass] == classier
          cl.delete klass
        else
          cl[klass].gsub!(/#{classier}\s?/, "")
        end
      end

      def extra_classes klass, type=:private
        klass = klass.first if klass.is_a?(Array)
        klass = klass.to_s

        next_ancestor&.extra_classes(klass, :public)
        [class_list(type)[klass], (class_list(:public)[klass] if type == :private),
         next_ancestor&.extra_classes(klass, :public)].flatten.compact.join(" ")
      end

      private

      def class_list type=:private
        case type
        when :private
          @private_class_list ||= {}
        when :public
          @public_class_list ||= {}
        else
          raise ArgumentError, "#{type} not a valid class list"
        end
      end

      def class_list_type scope
        case scope
        when :self
          :private
        when :nested, :parent_nested, :global
          :public
        else
          raise ArgumentError, "invalid class_up scope: #{scope}"
        end
      end
    end
  end
end
