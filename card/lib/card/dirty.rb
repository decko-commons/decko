class Card
  module Dirty
    require "card/dirty/method_factory"
    extend ::Card::Dirty::MethodFactory

    %i[name db_content trash type_id].each do |field|
      define_dirty_methods field
    end

    def attribute_before_act attr
      if saved_change_to_attribute? attr
        attribute_before_last_save attr
      elsif will_save_change_to_attribute? attr
        mutations_from_database.changed_values[attr]
      elsif not_in_callback?
        attribute_was attr
      else
        _read_attribute attr
      end
    end

    def not_in_callback?
      # or in integrate_with_delay stage
      mutations_before_last_save.equal?(mutations_from_database)
    end

    def attribute_is_changing? attr
      if not_in_callback?
        attribute_changed? attr
      else
        saved_change_to_attribute?(attr) ||
          will_save_change_to_attribute?(attr)
      end
    end
  end
end
