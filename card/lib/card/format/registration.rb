class Card
  class Format
    module Registration
      def register format
        registered << format.to_s
        self.symbol = format
      end

      def new card, opts={}
        if self != Format
          super
        else
          klass = format_class opts
          self == klass ? super : klass.new(card, opts)
        end
      end

      def format_class opts
        return opts[:format_class] if opts[:format_class]

        format = opts[:format] || :html
        class_from_name format_class_name(format)
      end

      def format_class_name format
        format = format.to_s
        format = "" if format == "base"
        format = aliases[format] if aliases[format]
        "#{format.camelize}Format"
      end

      def class_from_name formatname
        if formatname == "Format"
          Card::Format
        else
          Card::Format.const_get formatname
        end
      end

      def format_ancestry
        ancestry = [self]
        ancestry += superclass.format_ancestry unless self == Card::Format
        ancestry
      end

      def symbol
        @symbol ||= symbol_from_classname
      end
      alias_method :to_sym, :symbol

      private

      def symbol_from_classname
        match = to_s.match(/::(?<format>[^:]+)Format/)
        raise "no symbol for #{self.class}" unless match

        match[:format].underscore.to_sym
      end
    end
  end
end
