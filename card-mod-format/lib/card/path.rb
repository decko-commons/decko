class Card
  # Generate standard card paths.
  class Path
    def initialize card, opts
      @card = card
      @opts = opts
    end

    def render
      new_cardtype || standard
    end

    private

    def opts
      @opts
    end

    def action
      @action ||= opts.delete(:action)&.to_sym
    end

    def new_cardtype
      return unless new_cardtype?

      "#{action}/#{mark}#{query}"
    end

    def new_cardtype?
      return false unless action.in? %i[new type]

      # "new" and "type" are not really an action and are only
      # a valid value here for this path
      opts[:mark].present?
    end

    def standard
      base + extension + query
    end

    def base
      explicit_action? ? action_base : mark
    end

    def action_base
      mark.present? ? "#{action}/#{mark}" : "card/#{action}"
      # the card/ prefix prevents interpreting action as cardname
    end

    def explicit_action?
      action.in? %i[create update delete]
    end

    def mark
      @mark ||= (markless? ? "" : interpret_mark)
    end

    def interpret_mark
      name = handle_unknown do
        opts[:mark] ? Card::Name[opts.delete(:mark)] : @card.name
      end
      name.url_key
    end

    def markless?
      action == :create || no_mark?
    end

    def no_mark?
      @no_mark ||= opts.delete :no_mark
    end

    def extension
      extension = opts.delete :format
      extension ? ".#{extension}" : ""
    end

    def query
      query_opts = cast_path_hash opts
      query_opts.empty? ? "" : "?#{query_opts.to_param}"
    end

    # normalizes certain path opts to specified data types
    def cast_path_hash hash, cast_hash=nil
      return hash unless hash.is_a? Hash
      cast_each_path_hash hash, (cast_hash || CAST_PARAMS)
      hash
    end

    def cast_each_path_hash hash, cast_hash
      hash.each do |key, value|
        next unless (cast_to = cast_hash[key])
        hash[key] = cast_path_value value, cast_to
      end
    end

    def cast_path_value value, cast_to
      if cast_to.is_a? Hash
        cast_path_hash value, cast_to
      else
        send "cast_path_value_as_#{cast_to}", value
      end
    end

    def cast_path_value_as_array value
      Array.wrap value
    end

    def handle_unknown
      yield.tap do |name|
        return name if name_specified? || name_standardish?(name) || Card.known?(name)
        opts[:card] ||= {}
        opts[:card][:name] = name
      end
    end

    def name_specified?
      opts.dig :card, :name
    end

    # no name info will be lost by using url_key
    def name_standardish? name
      name.s == Card::Name.url_key_to_standard(name.url_key)
    end
  end
end