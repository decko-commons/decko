class Card
  module Dirty
    # handles special method definitions for dirty cards
    module MethodFactory
      def define_dirty_methods field
        define_method "#{field}_before_act" do
          attribute_before_act field
        end

        define_method "#{field}_is_changing?" do
          attribute_is_changing? field
        end
      end
    end
  end
end
