class Card
  module Set
    # supports requiring field cards
    # for example, if A requires a B field, then you cannot create A without also
    # creating A+B
    class RequiredField
      attr_reader :parent_set, :field, :options

      def initialize parent_set, field, options={}
        @parent_set = parent_set
        @field = field
        @options = options
      end

      def add
        create_parent_event
        return unless field_events?

        define_field_test
        create_field_events
      end

      def parent_event_name
        [parent_set.underscored_name, "requires_field", field].join("__").to_sym
      end

      def field_event_name action
        [field, "required_by", parent_set.underscored_name, "on", action]
          .join("__").to_sym
      end

      private

      def define_field_test
        return unless (test = event_test)

        method_name = field_test_name
        field_set.class_exec do
          define_method method_name do
            left.send test
          end
        end
      end

      def field_test_name
        return unless event_test

        :"_when_left_#{event_test}"
      end

      def event_test
        return @event_test unless @event_test.nil?

        test = options[:when]
        @event_test = test.is_a?(Symbol) ? test : false
      end

      def field_set
        @field_set ||= ensure_field_set parent_set, field
      end

      # for now, we only support field events on type sets. That's because only type sets
      # have fields that are set-addressable (via type plus right sets)
      def field_events?
        parent_set.type_set?
      end

      def create_field_events
        create_field_event :delete, "deleted", :trashed_left?
        create_field_event :update, "renamed", :same_field?, changing: :name
      end

      def field_event_options action, extra_options
        options = { on: action }.merge extra_options
        options[:when] = field_test_name if event_test
        options
      end

      def create_field_event action, action_verb, allow_test, extra_options={}
        event_name = field_event_name action
        event_options = field_event_options action, extra_options
        field_set.class_exec(self) do |required|
          event event_name, :validate, event_options  do
            return if send allow_test

            errors.add required.field, "can't be #{action_verb}; required field"
          end
        end
      end

      def create_parent_event
        parent_set.class_exec(self) do |required|
          event required.parent_event_name, :validate,
                required.options.merge(on: :create) do
            return if field?(required.field) || left&.type_id == Card::CardtypeID

            # Without the Cardtype exemption, we can get errors on type plus right sets
            # eg, if right/account has require_field :email, then when we're trying
            # to create User+*account+*type_plus right rules, it fails, because
            # User+*account doesn't have an +email field.
            #
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
