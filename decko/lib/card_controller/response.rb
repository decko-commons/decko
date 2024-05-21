class CardController
  # methods for managing decko responses
  module Response
    def response_format
      @response_format ||= format_name_from_params
    end

    private

    def respond format, result, status
      if status.in? [302, 303]
        hard_redirect result
      elsif format.is_a?(Card::Format::FileFormat) && status == 200
        send_file(*result)
      else
        render_response result.to_s.html_safe, status, format.mime_type
      end
    end

    def render_response body, status, content_type
      render body: body, status: status, content_type: content_type
    end

    def redirect_cud_success success
      redirect_type = success.redirect || default_cud_success_redirect_type
      if redirect_type.to_s == "soft"
        success.target ||= self
        soft_redirect success
      else
        hard_redirect success.to_url, 303
      end
    end

    def default_cud_success_redirect_type
      Card::Env.ajax? ? "soft" : "hard"
    end

    # return a redirect response
    def hard_redirect url, status=302
      url = card_url url # make sure we have absolute url
      if Card::Env.ajax?
        # lets client reset window location
        # (not just receive redirected response)
        # formerly used 303 response, but that gave IE the fits
        render json: { redirect: url }
      else
        redirect_to url, status: status
      end
    end

    # return a standard GET response directly.
    # Used in AJAX situations where PRG pattern is unwieldy
    def soft_redirect success
      # Card::Cache.renew
      @card = success.target
      require_card_for_soft_redirect!
      self.params = soft_redirect_params
      Card::Env.reset self
      load_action
      show
    end

    def soft_redirect_params
      new_params = params.clone
      new_params.delete :card
      new_params.delete :action
      new_params.merge Card::Env.success.params
    end

    def reload
      render json: { reload: true }
    end

    def slotter_magic_response
      render json: { magic: true }
    end

    def slotter_magic?
      params["slotter_mode"]&.in? %w[silent-success update-modal-origin update-origin]
    end

    def require_card_for_soft_redirect!
      return if card.is_a? Card

      raise Card::Error, "tried to do soft redirect without a card"
    end

    # TODO: everything below should go in a separate file
    # below is about beginning (initialization).  above is about end (response)
    # Both this file and that would make sense as submodules of CardController

    def load_format status
      request.format = :html if implicit_html?
      card.format(response_format).tap { |fmt| fmt.error_status = status }
    end

    def implicit_html?
      (Card::Env.ajax? && !params[:format]) || request.format.to_s == "*/*"
    end

    def format_name_from_params
      return :file if explicit_file_format?

      (params[:format].present? ? params[:format] : request.format).to_sym
    end

    def explicit_file_format?
      params[:explicit_file] || !Card::Format.registered.member?(request.format)
    end
  end
end
