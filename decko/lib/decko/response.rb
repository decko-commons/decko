module Decko
  # methods for managing decko responses
  module Response
    private
    def card_redirect url
      url = card_url url # make sure we have absolute url
      if Card::Env.ajax?
        # lets client reset window location
        # (not just receive redirected response)
        # formerly used 303 response, but that gave IE the fits
        render json: { redirect: url }
      else
        redirect_to url
      end
    end

    def deliver format, result, status
      if status == 302
        card_redirect result
      elsif format.is_a?(Card::Format::FileFormat) && status == 200
        send_file(*result)
      else
        render body: result.to_s.html_safe,
               status: status,
               content_type: format.mime_type
      end
    end

    def reset_card new_card
      @card = new_card
      update_params_for_success
      @card.select_action_by_params params
    end

    def update_params_for_success
      success = Card::Env.success
      Card::Env[:params] =
        self.params =
          success.soft_redirect? ? success.params : params.merge(success.params)
    end

    def send_deprecated_asset
      filename = [params[:filename], params[:format]].join(".")
      # for security, block relative paths
      raise Decko::BadAddress if filename.include? "../"
      path = Decko::Engine.paths["gem-assets"].existent.first
      send_file File.join(path, filename), x_sendfile: true
    end

    def format_from_params card
      card.format format_name_from_params
    end

    def format_name_from_params
      return :file if params[:explicit_file]
      format = request.parameters[:format]
      # unknown format
      return :file unless Card::Format.registered.member?(format)
      format.to_sym
    end

    def interpret_id id
      case id
      when "*previous" then
        return card_redirect(Card::Env.previous_location)
      when nil then
        determine_id
      else
        validate_id_encoding id
      end
    end

    def determine_id
      case
      when prompt_setup?
        prepare_setup_card!
      when params[:card] && params[:card][:name]
        params[:card][:name]
      when Card::Format.tagged(params[:view], :unknown_ok)
        ""
      else
        Card.global_setting(:home) || "Home"
      end
    end

    def prompt_setup?
      Card::Auth.needs_setup? && Card::Env.html?
    end

    def prepare_setup_card!
      params[:card] = { type_id: Card.default_accounted_type_id }
      params[:view] = "setup"
      ""
    end

    def validate_id_encoding id
      # we should find the place where we produce these bad urls
      id.valid_encoding? ? id : id.force_encoding("ISO-8859-1").encode("UTF-8")
    end

    def use_draft?
      params[:edit_draft] && card.drafts.present?
    end
  end
end
