class Card
  # Generate standard card paths.
  class Path
    include CastParams

    def initialize card, opts
      @card = card
      @opts = opts
    end

    def render
      new_cardtype || standard
    end

    private

    attr_reader :opts

    def new_cardtype
      # "new" and "type" are not really an action and are only
      # a valid value here for this path
      return unless action.in?(%i[new type]) && mark.present?

      "#{action}/#{mark}#{query}"
    end

    def standard
      anch = anchor
      base + extension + query + anch
    end

    def base
      if action.in? %i[create update delete]
        action_base
      elsif mark.present? && view.present?
        "#{mark}/#{view}"
      else
        mark
      end
    end

    def action_base
      mark.present? ? "#{action}/#{mark}" : "card/#{action}"
      # the card/ prefix prevents interpreting action as cardname
    end

    def action
      @action ||= opts.delete(:action)&.to_sym
    end

    def view
      @view ||= opts.delete :view
    end

    def no_mark?
      @no_mark ||= opts.delete :no_mark
    end

    def mark
      @mark ||= (markless? ? "" : interpret_mark)
    end

    def interpret_mark
      name = handle_unknown do
        opts[:mark] ? Card::Name[opts.delete(:mark)] : @card.name
      end
      name&.url_key.to_s
    end

    def markless?
      action == :create || no_mark?
    end

    def extension
      extension = opts.delete :format
      extension ? ".#{extension}" : ""
    end

    def anchor
      anchor = opts.delete :anchor
      anchor ? "##{anchor}" : ""
    end

    def query
      query_opts = cast_path_hash opts
      query_opts.empty? ? "" : "?#{query_opts.to_param}"
    end

    def handle_unknown
      yield.tap do |name|
        return name if name.nil? || known_name?(name)

        opts[:card] ||= {}
        opts[:card][:name] = name
      end
    end

    def known_name? name
      name_specified? || name_standardish?(name) || Card.known?(name)
    end

    def name_specified?
      opts.dig :card, :name
    end

    # no name info will be lost by using url_key
    def name_standardish? name
      name.url_key == name.tr(" ", "_")
    end
  end
end
