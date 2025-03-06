class CardController
  # methods for interpretation of card marks requested
  module Mark
    private

    def load_mark
      params[:mark] = interpret_mark params[:mark]
    end

    def interpret_mark mark
      case mark
      when "*previous"
        # Why support this? It's only needed in Success, right? Deprecate?
        hard_redirect Card::Env.previous_location
      when nil
        implicit_mark
      else
        explicit_mark mark
      end
    end

    def explicit_mark mark
      # we should find the place where we produce these bad urls
      # mark.valid_encoding? ? mark : mark.force_encoding("ISO-8859-1").encode("UTF-8")
      mark
    end

    def implicit_mark
      case
      when initial_setup?
        prepare_setup_card! # alters params
        ""
      when (name = mark_from_card_hash)
        name
      when view_does_not_require_name?
        ""
      else
        home_mark
      end
    end

    def home_mark
      Card::Rule.global_setting(:home) || "Home"
    end

    def view_does_not_require_name?
      return false unless (view = params[:view]&.to_sym)

      Card::Set::Format::AbstractFormat::ViewOpts.unknown_ok[view]
    end

    def mark_from_card_hash
      params.dig :card, :name
    end

    def initial_setup?
      Card::Auth.needs_setup? && Card::Env.html?
    end

    def prepare_setup_card!
      params[:card] = { type_id: Card.default_accounted_type_id }
      params[:view] = "setup"
    end
  end
end
