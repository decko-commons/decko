# -*- encoding : utf-8 -*-

# Decko's only controller.
class CardController < ApplicationController
  include ::Card::Env::Location
  include ::Recaptcha::Verify
  include ::Decko::Response

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
    Card::Auth.signin_with token: params[:token], api_key: params[:api_key]
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
    yield ? cud_success : raise(Card::Error::UserError)
  end

  # successful create, update, or delete act
  def cud_success
    success = Card::Env.success.in_context card.name
    if success.reload?
      reload # instruct JSON to reload
    else
      redirect_cud_success success
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
    view ||= view_from_params
    card.act do
      format.page self, view, Card::Env.slot_opts
    end
  end

  def view_from_params
    params[:view] || params[:v]
  end

  def handle_exception exception
    raise exception if debug_exception?(exception)
    @card ||= Card.new
    error = Card::Error.report exception, card
    show error.class.view, error.class.status_code
  end

  # TODO: move to exception object
  # ARDEP: exceptions RecordInvalid
  def debug_exception? e
    !e.is_a?(Card::Error::UserError) &&
      !e.is_a?(ActiveRecord::RecordInvalid) &&
      Card::Codename[:debugger] &&
      Card[:debugger]&.content =~ /on/  # && !Card::Env.ajax?
  end

  class << self
    def rescue_from_class *klasses
      klasses.each do |klass|
        rescue_from(klass) { |exception| handle_exception exception }
      end
    end

    def rescue_all?
      Cardio.config.rescue_all_in_controller
    end
  end

  rescue_from_class(*Card::Error::UserError.user_error_classes)
  rescue_from_class StandardError if rescue_all?
end
