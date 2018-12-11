# -*- encoding : utf-8 -*-

require_dependency "card"
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
    handle { card.save! }
  end

  def read
    show
  end

  def update
    card.new_card? ? create : handle { card.update! params[:card] }
  end

  def delete
    handle { card.delete! }
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
  before_action :load_mark, only: [:read]
  before_action :load_card, except: [:asset]
  before_action :load_action, only: [:read]
  before_action :refresh_card, only: [:create, :update, :delete]

  def setup
    Card::Machine.refresh_script_and_style unless params[:explicit_file]
    Card::Cache.renew
    Card::Env.reset controller: self
  end

  def authenticate
    Card::Auth.set_current params[:token], params[:current]
  end

  def load_mark
    params[:mark] = interpret_mark params[:mark]
  end

  def load_card
    @card = Card.controller_fetch params
    raise Card::Error::NotFound unless card
    record_as_main
  end

  def load_action
    card.select_action_by_params params
    card.content = card.last_draft_content if params[:edit_draft] && card.drafts.present?
  end

  # TODO: refactor this away this when new layout handling is ready
  def record_as_main
    Card::Env[:main_name] = params[:main] || card&.name || ""
  end

  def refresh_card
    @card = card.refresh
  end

  # ----------( HELPER METHODS ) -------------

  def handle
    Card::Env.success card.name
    yield ? render_success : raise(Card::Error::UserError)
  end

  # successful create, update, or delete action
  def render_success
    success = Card::Env.success.in_context card.name
    if Card::Env.ajax? && !success.hard_redirect?
      soft_redirect success
    else
      hard_redirect success.to_url
    end
  end

  def show view=nil, status=200
    card.action = :read
    format = load_format
    result = render_page format, view
    status = format.error_status || status
    respond format, result, status
  end

  def render_page format, view
    view ||= params[:view]
    card.act do
      format.page self, view, Card::Env.slot_opts
    end
  end

  def handle_exception exception
    @card ||= Card.new
    Card::Error.current = exception
    error = Card::Error.cardify_exception exception, card
    error.report
    show error.class.view, error.class.status_code
  end

  class << self
    def rescue_from_class klass
      rescue_from(klass) { |exception| handle_exception exception }
    end
  end

  rescue_from_class ActiveRecord::RecordInvalid
  rescue_from_class(Rails.env.development? ? Card::Error::UserError : StandardError)
end
