class CardController
  # helper method for RESTful action methods for card
  module Rest
    include ActionController::HttpAuthentication::Token

    def create
      handle { card.save! }
    end

    def read
      show
    end

    def update
      card.new_card? ? create : handle { card.update! params[:card]&.to_unsafe_h }
    end

    def delete
      handle { card.delete! }
    end

    # @deprecated
    def asset
      body = "Decko installation error: missing public directory symlinks"
      Rails.logger.info "#{body}.\n  >>> Try `rake card:mod:symlink`"
      render body: body, status: 404
    end

    private

    def setup
      Card::Cache.renew
      Card::Assets.refresh unless params[:explicit_file]
      Card::Env.reset self
    end

    def authenticate
      Card::Auth.signin_with(**authenticators)
    end

    def authenticators
      request ? { token: token_from_header || params[:token] } : {}
    end

    def token_from_header
      token_and_options(request)&.first
    end

    def load_card
      @card = Card.uri_fetch params
      raise Card::Error::NotFound unless card

      record_as_main
    end

    def load_action
      card.select_action_by_params params
      return unless params[:edit_draft] && card.drafts.present?

      card.content = card.last_draft_content
    end

    # TODO: refactor this away this when new layout handling is ready
    def record_as_main
      Card::Env.main_name = params[:main] || card&.name || ""
    end

    def refresh_card
      @card = card.refresh
    end

    # ----------( HELPER METHODS ) -------------

    def handle
      Card::Env.success card.name
      yield ? cud_success : raise(Card::Error::UserError)
    end

    # successful create, update, or delete act
    def cud_success
      success = Card::Env.success.in_context card.name
      if success.reload?
        reload # instruct JSON to reload
      elsif slotter_magic?
        slotter_magic_response
      else
        redirect_cud_success success
      end
    end

    def show view=nil, status=200
      card.action = :read
      format = load_format status
      result = render_page format, view
      status = format.error_status || status
      respond format, result, status
    end

    def render_page format, view
      view ||= view_from_params
      card.act do
        format.page self, view, Card::Env.slot_opts
      end
    end

    def view_from_params
      %i[view v].each { |k| return params[k] if params[k].present? }
      nil
    end
  end
end
