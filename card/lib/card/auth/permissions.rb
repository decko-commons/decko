class Card
  module Auth
    # singleton permission methods
    module Permissions
      RECAPTCHA_DEFAULTS = {
        recaptcha_site_key: "6LdoqpgUAAAAAEdhJ4heI1h3XLlpXcDf0YubriCG",
        recaptcha_secret_key: "6LdoqpgUAAAAAP4Sz1L5PY6VKum_RFxq4-awj4BH"
      }.freeze

      # user has "root" permissions
      # @return [true/false]
      def always_ok?
        usr_id = as_id
        return false unless usr_id

        always_ok_usr_id? usr_id
      end

      # specified user has root permission
      # @param usr_id [Integer]
      # @return [true/false]
      def always_ok_usr_id? usr_id, force_cache_update=false
        return true if usr_id == Card::WagnBotID # cannot disable

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
                not: { codename: ["in"] + Card.config.non_createable_types } },
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
        Card[user_id].all_enabled_roles.include? role_id
      end
    end
  end
end
