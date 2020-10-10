class Card
  module Auth
    # singleton permission methods
    module Permissions
      # user has "root" permissions
      # @return [true/false]
      def always_ok?
        usr_id = as_id
        case usr_id
        when Card::WagnBotID then true # cannot disable
        when nil             then false
        else
          always_ok_usr_id? usr_id
        end
      end

      # specified user has root permission
      # @param usr_id [Integer]
      # @return [true/false]
      def always_ok_usr_id? usr_id, force_cache_update=false
        always = always_cache
        if always[usr_id].nil? || force_cache_update
          update_always_cache usr_id, admin?(usr_id)
        else
          always[usr_id]
        end
      end

      def update_always_cache usr_id, value
        always = always_cache
        always = always.dup if always.frozen?
        always[usr_id] = value
        Card.cache.write "ALWAYS", always
        value
      end

      def always_cache
        Card.cache.read("ALWAYS") || {}
      end

      # list of names of cardtype cards that current user has perms to create
      # @return [Array of strings]
      def createable_types
        type_names =
          Auth.as_bot do
            Card.search(
              { type: Card::CardtypeID, return: :name,
                not: { codename: ["in"] + Cardio.config.non_createable_types } },
              "find createable types"
            )
          end

        type_names.select do |name|
          Card.new(type: name).ok? :create
        end.sort
      end

      # test whether user is an administrator
      # @param user_id [Integer]
      # @return [true/false]
      def admin? user_id
        has_role? user_id, Card::AdministratorID
      end

      def has_role? user_id, role_id
        return false unless user_id && role_id

        Card[user_id].all_enabled_roles.include? role_id
      end
    end
  end
end
