# -*- encoding : utf-8 -*-

# Decko's only controller.
class CardController < ActionController::Base
  include Mark
  include Rest
  include Response
  include Errors
  extend Errors::Rescue

  # NOTE: including Card::Env::Location triggers card loading, which triggers mod loading,
  # which can include initializers that add to the CardController class.
  # It's important that it come *after* the modules above, so that mod modules
  # can override them.
  include ::Card::Env::Location

  layout nil
  attr_reader :card, :format

  before_action :setup, except: [:asset]
  before_action :authenticate, except: [:asset]
  before_action :load_mark, only: [:read]
  before_action :load_card, except: [:asset]
  before_action :load_action, only: [:read]
  before_action :refresh_card, only: %i[create update delete]

  rescue_from_class(*Card::Error::UserError.user_error_classes)
  rescue_from_class StandardError if rescue_all?
end
