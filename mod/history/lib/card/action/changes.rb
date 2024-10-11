class Card
  class Action
    # methods for relating Card::Action to Card::Change
    module Changes
      # value set by action's {Change} to given field
      # @see #interpret_field #interpret_field for field param
      # @see #interpret_value #interpret_value for return values
      def value field
        return unless (change = change field)

        interpret_value field, change.value
      end

      # value of field set by most recent {Change} before this one
      # @see #interpret_field #interpret_field for field param
      # @see #interpret_field  #interpret_field for field param
      def previous_value field
        return if action_type == :create
        return unless (previous_change = previous_change field)

        interpret_value field, previous_change.value
      end

      # action's {Change} object for given field
      # @see #interpret_field #interpret_field for field param
      # @return [Change]
      def change field
        changes[interpret_field field]
      end

      # most recent change to given field before this one
      # @see #interpret_field #interpret_field for field param
      # @return [Change]
      def previous_change field
        return nil if action_type == :create

        field = interpret_field field
        if @previous_changes&.key?(field)
          @previous_changes[field]
        else
          @previous_changes ||= {}
          @previous_changes[field] = card.last_change_on field, before: self
        end
      end

      def all_changes
        self.class.cache.fetch("#{id}-changes") do
          # using card_changes causes caching problem
          Card::Change.where(card_action_id: id).to_a
        end
      end

      # all action {Change changes} in hash form. { field1: Change1 }
      # @return [Hash]
      def changes
        @changes ||=
          if sole?
            current_changes
          else
            all_changes.each_with_object({}) do |change, hash|
              hash[change.field.to_sym] = change
            end
          end
      end

      # all changed values in hash form. { field1: new_value }
      def changed_values
        @changed_values ||= changes.transform_values(&:value)
      end

      # @return [Hash]
      def current_changes
        return {} unless card

        @current_changes ||=
          Card::Change::TRACKED_FIELDS.each_with_object({}) do |field, hash|
            hash[field.to_sym] = Card::Change.new field: field,
                                                  value: card.send(field),
                                                  card_action_id: id
          end
      end

      private

      # translate field into fieldname as referred to in database
      # @see Change::TRACKED_FIELDS
      # @param field [Symbol] can be :type_id, :cardtype, :db_content, :content,
      #     :name, :trash
      # @return [Symbol]
      def interpret_field field
        case field
        when :content then :db_content
        when :cardtype then :type_id
        else field.to_sym
        end
      end

      # value in form prescribed for specific field name
      # @param value [value of {Change}]
      # @return [Integer] for :type_id
      # @return [String] for :name, :db_content, :content, :cardtype
      # @return [True/False] for :trash
      def interpret_value field, value
        case field.to_sym
        when :type_id   then value&.to_i
        when :cardtype  then value&.to_i&.cardname
        else                 value
        end
      end
    end
  end
end
