class Card
  module SpecHelper
    # To be included in Card.
    # Defines helper to change card sets and formats
    module SetHelper
      # define dynamically views (or other things) on format objects
      # @return format object
      #
      # @example add a view to a card's html format
      # format =
      #   Card["A"].format_with(:html) do
      #     view :my_test_view do
      #       card.name
      #     end
      #   end
      # format.render :my_test_view  # => "A"
      def format_with format_type=:html, &block
        dynamic_set =
          create_dynamic_set do
            format format_type, &block
          end
        format_with_set dynamic_set, format_type
        #::Card::Set::Self::DynamicSet, :html
      end

      # define dynamically a self set on a card object
      # @return card object
      #
      # @example add a method to a card
      # Card["A"].set_with do
      #   def special_method; end
      # end
      def set_with &block
        with_set create_dynamic_set(&block)
      end

      # load set into card object
      def with_set set
        set.modules.each do |modul|
          singleton_class.include modul
        end
        yield set if block_given?
        self
      end

      # load set into a card's format object
      def format_with_set set, format_type=:base
        format = format format_type
        set.format_modules(format_type).each do |modul|
          next if format.is_a? modul
          format.singleton_class.include modul
        end
        block_given? ? yield(format) : format
      end

      def set_format_class set, format_type
        format_class = Card::Format.format_class_name format_type
        set.const_get format_class
      end

      private

      def create_dynamic_set &block
        ::Card::Set::Type.const_remove_if_defined :DynamicSet
        ::Card::Set::Type.const_set :DynamicSet, Module.new
        ::Card::Set::Type::DynamicSet.extend Card::Set
        ::Card::Set::Type::DynamicSet.module_eval(&block)
        ::Card::Set::Type::DynamicSet
      end
    end
  end
end
