class Card
  module Set
    class RequiredField
      attr_reader :parent_set, :field_set, :field

      def initialize parent_set, field
        @parent_set = parent_set
        @field_set = ensure_field_set parent_set, field
        @field = field
      end

      def add
        create_parent_event
        create_field_events
      end

      def parent_event_name
        [parent_set.underscore, "requires_field", field_set.underscore].join("__").to_sym
      end

      def field_event_name action
        [field_set.underscore, "required_by", parent_set.underscore, "on", action].join("__").to_sym
      end

      private

      def create_field_events
        create_field_delete_event
        create_field_rename_event
      end

      def create_field_delete_event
        field_set.class_exec(self) do |required|
          event required.field_event_name(:delete), :validate, on: :delete do
            return if left&.trash || left&.singleton_class&.include?(required.parent_set)

            errors.add required.field, "can't be deleted; required field of #{left.name}" # LOCALIZE
          end
        end
      end

      def create_field_rename_event
        field_set.class_exec(self) do |required|
          event required.field_event_name(:update), :validate,
                on: :update, changing: :name do
            return if superleft&.attribute_is_changing? :name

            parent = Card.fetch(name_before_act.to_name.left)
            return if !parent || parent&.singleton_class&.include?(required.parent_set)

            errors.add :name, "can't be renamed; required field of #{parent.name}" # LOCALIZE
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

      def ensure_field_set some_set, field
        field_set = some_set.ensure_set { "Right::#{field.to_s.capitalize}" }
        Card::Set.register_set field_set
        field_set
      end
    end
  end
end



