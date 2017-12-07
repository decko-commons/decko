# -*- encoding : utf-8 -*-

require_dependency "card"

require_dependency "decko/exceptions"
require_dependency "decko/response"
require_dependency "card/mailer"  # otherwise Net::SMTPError rescues can cause
# problems when error raised comes before Card::Mailer is mentioned

# Decko's only controller.
class CardController < ActionController::Base
  include Card::Env::Location
  include Recaptcha::Verify
  include Decko::Response

  layout nil
  attr_reader :card

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #  PUBLIC METHODS

  def create
    handle { card.save }
  end

  def read
    show
  end

  def update
    card.new_card? ? create : handle { card.update_attributes params[:card] }
  end

  def delete
    handle { card.delete }
  end

  # @deprecated
  def asset
    Rails.logger.info "Routing assets through Card. Recommend symlink from " \
                      'Deck to Card gem using "rake decko:update_assets_symlink"'
    send_deprecated_asset
  end

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #  PRIVATE METHODS

  private

  #-------( FILTERS )

  before_action :setup, except: [:asset]
  before_action :authenticate, except: [:asset]
  before_action :load_id, only: [:read]
  before_action :load_card, except: [:asset]
  before_action :refresh_card, only: [:create, :update, :delete]

  def setup
    request.format = :html unless params[:format] # is this used??
    Card::Machine.refresh_script_and_style
    Card::Cache.renew
    Card::Env.reset controller: self
  end

  def authenticate
    Card::Auth.set_current params[:token], params[:current]
  end

  def load_id
    params[:id] = interpret_id params[:id]
  end

  def load_card
    @card = Card.controller_fetch params
    raise Card::Error::NotFound unless @card
    load_action
    record_as_main
    card.errors.any? ? render_errors : true
  end

  def load_action
    @card.select_action_by_params params
  end

  def record_as_main
    Card::Env[:main_name] = params[:main] || card&.name || ""
  end

  def refresh_card
    @card = card.refresh
  end

  # ----------( HELPER METHODS ) -------------

  def handle
    card.act(success: true) do
      yield ? render_success : render_errors
    end
  end

  def render_success
    success = Card::Env.success
    success.name_context = @card.name
    if !Card::Env.ajax? || success.hard_redirect?
      card_redirect success.to_url
    elsif success.target.is_a? String
      render! text: success.target
    else
      reset_card success.target
      show
    end
  end

  def show view=nil, status=200
    card.action = :read
    card.content = card.last_draft_content if use_draft?

    format = format_from_params card
    result = render_page format, view
    status = format.error_status || status
    deliver format, result, status
  end

  def render_page format, view
    view ||= params[:view]
    card.act do
      format.page self, view, Card::Env.slot_opts
    end
  end

  def render_errors
    view, status = Card::Error.view_and_status(card) || [:errors, 422]
    show view, status
  end

  rescue_from StandardError do |exception|
    Rails.logger.info "exception = #{exception.class}: #{exception.message}"
    @card ||= Card.new
    show Card::Error.exception_view(@card, exception)
  end
end
