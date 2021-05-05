# -*- encoding : utf-8 -*-

# Decko's only controller.
class CardController < ApplicationController
  include ::Card::Env::Location
  include Response
  include Errors
  include Rest
  include Mark

  layout nil
  attr_reader :card

  before_action :setup, except: [:asset]
  before_action :authenticate, except: [:asset]
  before_action :load_mark, only: [:read]
  before_action :load_card, except: [:asset]
  before_action :load_action, only: [:read]
  before_action :refresh_card, only: [:create, :update, :delete]
end
