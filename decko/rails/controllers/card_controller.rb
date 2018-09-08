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
    handle_errors do
      @card = Card.controller_fetch params
      raise Card::Error::NotFound unless card
      record_as_main
    end
  end

  def load_action
    handle_errors do
      card.select_action_by_params params
      if params[:edit_draft] && card.drafts.present?
        card.content = card.last_draft_content
      end
    end
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
    card.act(success: true) do
      yield ? render_success : render_errors
    end
  end

  def handle_errors
    yield
    card.errors.any? ? render_errors : true
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
    respond format, result, status
  end

  def render_page format, view
    view ||= params[:view]
    card.act do
      format.page self, view, Card::Env.slot_opts
    end
  end

  def render_errors
    show :errors, 422
  end

  rescue_from StandardError do |exception|
    @card ||= Card.new
    exception = Card::Error.cardify_exception exception
    # exception.report!
    show exception.class.view, exception.class.status
  end
end
