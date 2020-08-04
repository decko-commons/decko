class Card
  module Dirty
    extend ::Card::Dirty::MethodFactory

    %i[name db_content trash type_id left_id right_id codename].each do |field|
      define_dirty_methods field
    end

    { simple_name: :name, type: :type_id, content: :db_content }.each do |k, v|
      alias_method "#{k}_is_changing?", "#{v}_is_changing?"
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

    module DirtyNames
      def name_is_changing?
        super || left_id_is_changing? || right_id_is_changing?
      end

      def name_before_last_save
        super || Card::Name[left_id_before_last_save, right_id_before_last_save]
      end

      def name_before_act
        super || Card::Name[left_id_before_act, right_id_before_act]
      end
    end
    include DirtyNames
  end
end
