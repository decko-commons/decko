class Card
  module Set
    class RequiredField
      attr_reader :parent_set, :field

      def initialize parent_set, field
        @parent_set = parent_set
        @field = field
      end

      def add
        create_parent_event
        create_field_events if field_events?
      end

      def parent_event_name
        [parent_set.underscore, "requires_field", field].join("__").to_sym
      end

      def field_event_name action
        [field, "required_by", parent_set.underscore, "on", action].join("__").to_sym
      end

      private

      def field_set
        @field_set ||= ensure_field_set parent_set, field
      end

      def field_events?
        parent_set.type_set?
      end

      def create_field_events
        create_field_delete_event
        create_field_rename_event
      end

      def create_field_delete_event
        field_set.class_exec(self) do |required|
          event required.field_event_name(:delete), :validate, on: :delete do
            return if left&.trash || left&.include_module?(required.parent_set)

            errors.add required.field, "can't be deleted; required field of #{left.name}"
            # LOCALIZE
          end
        end
      end

      def create_field_rename_event
        field_set.class_exec(self) do |required|
          event required.field_event_name(:update), :validate,
                on: :update, changing: :name do
            return if superleft&.attribute_is_changing? :name

            parent = Card.fetch(name_before_act.to_name.left)
            return if !parent || parent&.include_module?(required.parent_set)

            errors.add :name, "can't be renamed; required field of #{parent.name}"
            # LOCALIZE
          end
        end
      end

      def create_parent_event
        parent_set.class_exec(self) do |required|
          event required.parent_event_name, :validate, on: :create do
            return if field?(required.field) || left&.type_id == CardtypeID

            # Without the Cardtype exemption, we can get errors on type plus right sets
            # Need a better solution so we can require fields on cardtype+X cards, too.

            errors.add required.field, "required" # LOCALIZE
          end
        end
      end

      def ensure_field_set parent_set, field
        field_set = parent_set.ensure_set { field_set_name parent_set, field }
        Card::Set.register_set field_set
        field_set
      end

      def field_set_name parent_set, field
        "TypePlusRight::#{parent_set.set_name_parts.last}::#{field.to_s.capitalize}"
      end
    end
  end
end



