class Card
  module Auth
    # singleton permission methods
    module Permissions
      # user has "root" permissions
      # @return [true/false]
      def always_ok?
        case as_id
        when DeckoBotID then true # cannot disable
        when nil       then false
        else
          always_ok_cached?
        end
      end

      # list of names of cardtype cards that current user has perms to create
      # @return [Array of strings]
      def createable_types
        type_names =
          Auth.as_bot do
            Card.search(
              { type: Card::CardtypeID, return: :name,
                not: { codename: ["in"] + Set.basket[:non_createable_types] } },
              "find createable types"
            )
          end

        type_names.select do |name|
          Card.new(type: name).ok? :create
        end.sort
      end

      # test whether user is an administrator
      # @param user_mark [Cardish]
      # @return [true/false]
      def admin? user_mark=nil
        (user_mark || as_id).card&.admin?
      end

      def update_always_cache value
        always = always_cache
        always = always.dup if always.frozen?
        always[as_id] = value
        Card.cache.write "ALWAYS", always
        value
      end

      private

      # specified user has root permission
      # @return [true/false]
      def always_ok_cached?
        always = always_cache
        if always[as_id].nil?
          update_always_cache admin?
        else
          always[as_id]
        end
      end

      def always_cache
        Card.cache.read("ALWAYS") || {}
      end
    end
  end
end
