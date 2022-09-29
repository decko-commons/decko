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

      alias_method :create, :create_card
      alias_method :update, :update_card
      alias_method :create!, :create_card!
      alias_method :update!, :update_card!
      alias_method :delete, :delete_card
    end
  end
end
