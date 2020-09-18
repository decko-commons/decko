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
    # ARDEP: note how ! methods here should be the complete interface from Card::Model < ActiveModel when it needs AR methods and features. I think the solution is to have a 'naked' card that is just a Model, and a Card::Storage class that works like formatters to do view stuff. You need to card.to_storage to get the mutation functions used here
    module SaveHelper
      def with_user user_name
        Card::Auth.with current_id: Card.fetch_id(user_name) do
          yield
        end
      end

      def create_card name_or_args, content_or_args=nil
        # ARDEP: is there an AM create?
        Card.create! create_args(name_or_args, content_or_args)
      end

      def update_card name, content_or_args
        args = standardize_update_args name, content_or_args
        resolve_name_conflict args
        Card[name]&.update! args
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
        if name.is_a? Symbol
          return unless Card::Codename.exist? name
        end
        return unless Card.exist?(name)

        card = Card[name]
        card.update! codename: nil
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

      def codename_from_name name
        name.downcase.tr(" ", "_").tr(":*", "")
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

      # if card with same name exists move it out of the way
      def create_card! name_or_args, content_or_args=nil
        args = standardize_args name_or_args, content_or_args
        create_card args.reverse_merge(rename_if_conflict: :old)
      end

      def update_card! name, content_or_args
        args = standardize_update_args name, content_or_args
        update_card name, args.reverse_merge(rename_if_conflict: :new)
      end

      def create_or_update_card! name_or_args, content_or_args=nil
        args = standardize_args name_or_args, content_or_args
        create_or_update args.reverse_merge(rename_if_conflict: :new)
      end

      def add_style name, opts={}
        name.sub!(/^style\:?\s?/, "") # in case name is given with prefix
        # remove it so that we don't double it

        add_coderule_item name, "style",
                          opts[:type_id] || Card::ScssID,
                          opts[:to] || "*all+*style"
      end

      def add_script name, opts={}
        name.sub!(/^script\:?\s?/, "") # in case name is given with prefix
        # remove it so that we don't double it

        add_coderule_item name, "script",
                          opts[:type_id] || Card::CoffeeScriptID,
                          opts[:to] || "*all+*script"
      end

      def add_coderule_item name, prefix, type_id, to
        codename = "#{prefix}_#{name.tr(' ', '_').underscore}"
        name = "#{prefix}: #{name}"

        ensure_card name, type_id: type_id,
                          codename: codename
        Card[to].add_item! name
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

      def method_missing method, *args
        method_name, cardtype_card = extract_cardtype_from_method_name method
        return super unless method_name

        args = standardize_args(*args)
        send "#{method_name}_card", args.merge(type_id: cardtype_card.id)
      end

      def respond_to_missing? method, _include_private=false
        extract_cardtype_from_method_name(method) || super
      end

      def extract_cardtype_from_method_name method
        return unless method =~ /^(?<method_name>create|ensure)_(?<type>.+?)(?:_card)?$/

        type = Regexp.last_match[:type]
        cardtype_card = Card::Codename[type.to_sym] ? Card[type.to_sym] : Card[type]
        return unless cardtype_card&.type_id == Card::CardtypeID ||
                      cardtype_card&.id == Card::SetID

        [Regexp.last_match[:method_name], cardtype_card]
      end

      private

      def ensure_card_simplified name, args
        ensure_card_update(name, args) || Card.create!(add_name(name, args))
      end

      def ensure_card_update name, args
        card = Card[name]
        return unless card

        ensure_attributes card, args
        card
      rescue Card::Error::CodenameNotFound => _e
        false
      end

      def validate_setting setting
        unless Card::Codename.exist?(setting) &&
               Card.fetch_type_id(setting) == Card::SettingID
          raise ArgumentError, "not a valid setting: #{setting}"
        end
      end

      def normalize_trait_rule_args setting, value
        return value if value.is_a? Hash

        if Card.fetch_type_id([setting, :right, :default]) == Card::PointerID
          value = Array(value).to_pointer_content
        end
        { content: value }
      end

      # @return args
      def standardize_args name_or_args, content_or_args=nil
        if name_or_args.is_a?(Hash)
          name_or_args
        else
          add_name name_or_args, content_or_args || {}
        end
      end

      def hashify value_or_hash, key
        if value_or_hash.is_a?(Hash)
          value_or_hash
        elsif value_or_hash.nil?
          {}
        else
          { key => value_or_hash }
        end
      end

      def standardize_ensure_args name_or_args, content_or_args
        name = name_or_args.is_a?(Hash) ? name_or_args[:name] : name_or_args
        args = if name_or_args.is_a?(Hash)
                 name_or_args
               else
                 hashify content_or_args, :content
               end
        [name, args]
      end

      def standardize_update_args name_or_args, content_or_args
        return name_or_args if name_or_args.is_a?(Hash)

        hashify content_or_args, :content
      end

      def create_args name_or_args, content_or_args=nil
        args = standardize_args name_or_args, content_or_args
        resolve_name_conflict args
        args
      end

      def name_from_args name_or_args
        name_or_args.is_a?(Hash) ? name_or_args[:name] : name_or_args
      end

      def add_name name, content_or_args
        if content_or_args.is_a?(Hash)
          content_or_args.reverse_merge name: name
        else
          { content: content_or_args, name: name }
        end
      end

      def resolve_name_conflict args
        rename = args.delete :rename_if_conflict
        return unless args[:name] && rename

        args[:name] = Card.uniquify_name args[:name], rename
      end

      def ensure_attributes card, args
        subcards = card.extract_subcard_args! args
        update_args = changing_args card, args

        return if update_args.empty? && subcards.empty?

        # FIXME: use ensure_attributes for subcards
        card.update! update_args.merge(subcards: subcards, skip: :validate_renaming)
      end

      def changing_args card, args
        args.select do |key, value|
          if key =~ /^\+/
            subfields[key] = value
            false
          elsif key.to_sym == :name
            card.name.to_s != value
          elsif value.is_a? ::File
            # NOOP
          else
            card.send(key) != value
          end
        end
      end
    end
  end
end
