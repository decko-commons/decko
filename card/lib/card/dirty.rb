class Card
  # Special "dirty" handling for significant card fields.
  module Dirty
    extend ::Card::Dirty::MethodFactory

    class << self
      def dirty_fields
        %i[name db_content trash type_id left_id right_id codename]
      end

      def dirty_aliases
        { type: :type_id, content: :db_content }
      end

      def dirty_options
        dirty_fields + dirty_aliases.keys
      end
    end

    dirty_fields.each { |field| define_dirty_methods field }
    dirty_aliases.each { |k, v| alias_method "#{k}_is_changing?", "#{v}_is_changing?" }

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

  # Even special-er handling for dirty cardnames
  module DirtyNames
    def name_is_changing?
      super || left_id_is_changing? || right_id_is_changing?
    end

    # def name_before_last_save
    #   super || dirty_name(left_id_before_last_save, right_id_before_last_save)
    # end

    def name_before_act
      super || dirty_name(left_id_before_act, right_id_before_act)
    end

    def dirty_name left, right
      return unless left.present? && right.present?

      Card::Name[left, right]
    end
  end
end
