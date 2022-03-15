class Card
  module Model
    # API to create and update cards.
    # It is intended as a helper for "external" scripts
    # (seeding, testing, migrating, etc) and not for internal application code.
    # The general pattern is:
    # All methods use the ActiveRecord !-methods that throw exceptions if
    # somethings fails.
    # All !-methods in this module rename existing cards
    # to resolve name conflicts)
    module SaveHelper
      include SaveHelperHelper
      include SaveArguments

      def with_user user_name, &block
        Card::Auth.with(current_id: user_name.card_id, &block)
      end

      def create_card name_or_args, content_or_args=nil
        Card.create! create_args(name_or_args, content_or_args)
      end

      # if card with same name exists move it out of the way
      def create_card! name_or_args, content_or_args=nil
        args = standardize_args name_or_args, content_or_args
        create_card args.reverse_merge(rename_if_conflict: :old)
      end

      def update_card name, content_or_args
        args = standardize_update_args name, content_or_args
        resolve_name_conflict args
        Card[name]&.update! args
      end

      def update_card! name, content_or_args
        args = standardize_update_args name, content_or_args
        update_card name, args.reverse_merge(rename_if_conflict: :new)
      end

      def create_or_update_card name_or_args, content_or_args=nil
        name = name_from_args name_or_args

        if Card[name]
          args = standardize_update_args name_or_args, content_or_args
          update_card(name, args)
        else
          args = standardize_args name_or_args, content_or_args
          create_card(args)
        end
      end

      def delete_card name
        return unless Card.exist?(name)

        Card[name].delete!
      end

      def delete_code_card name
        return unless delete_code_card? name

        card = Card[name]
        card.update! codename: ""
        card.delete!
      end

      # create if card doesn't exist
      # updates existing card only if given attributes are different except the
      # name
      # @example if a card with name "under_score" exists
      #   ensure_card "Under Score"                 # => no change
      #   ensure_card "Under Score", type: :pointer # => changes the type to pointer
      #                                             #    but not the name
      def ensure_card name_or_args, content_or_args=nil
        name, args = standardize_ensure_args name_or_args, content_or_args
        ensure_card_simplified name, args
      end

      # like ensure_card but derives codename from name if no codename is given.
      # The derived codename is all lower case with underscores; "*" and ":" are removed
      def ensure_code_card name_or_args, content_or_args=nil
        name, args = standardize_ensure_args name_or_args, content_or_args
        args[:codename] = codename_from_name(name) unless args[:codename]
        ensure_card_simplified name, args
      end

      # create if card doesn't exist
      # updates existing card only if given attributes are different including
      # the name
      # For example if a card with name "under_score" exists
      # then `ensure_card "Under Score"` renames it to "Under Score"
      def ensure_card! name_or_args, content_or_args=nil
        name, args = standardize_ensure_args name_or_args, content_or_args
        ensure_card_simplified name, add_name(name, args)
      end

      # Creates or updates a trait card with codename and right rules.
      # Content for rules that are pointer cards by default
      # is converted to pointer format.
      # @example
      #   ensure_trait "*a_or_b", :a_or_b,
      #                default: { type_id: Card::PointerID },
      #                options: ["A", "B"],
      #                input: "radio"
      def ensure_trait name, codename, args={}
        ensure_card name, codename: codename
        args.each do |setting, value|
          ensure_trait_rule name, setting, value
        end
      end

      def ensure_trait_rule trait, setting, value
        validate_setting setting
        card_args = normalize_trait_rule_args setting, value
        ensure_card [trait, :right, setting], card_args
      end

      def create_or_update_card! name_or_args, content_or_args=nil
        args = standardize_args name_or_args, content_or_args
        create_or_update args.reverse_merge(rename_if_conflict: :new)
      end

      # TODO: this is too specific for this
      def add_script name, opts={}
        name.sub!(/^script:?\s?/, "") # in case name is given with prefix
        # remove it so that we don't double it

        add_coderule_item name, "script",
                          opts[:type_id] || Card::CoffeeScriptID,
                          opts[:to] || "*all+*script"
      end

      alias_method :create, :create_card
      alias_method :update, :update_card
      alias_method :create_or_update, :create_or_update_card
      alias_method :create!, :create_card!
      alias_method :update!, :update_card!
      alias_method :create_or_update!, :create_or_update_card!
      alias_method :ensure, :ensure_card
      alias_method :ensure!, :ensure_card!
      alias_method :delete, :delete_card
    end
  end
end
