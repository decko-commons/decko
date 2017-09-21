# -*- encoding : utf-8 -*-
require "carrierwave"

Object.const_remove_if_defined :Card

# Cards are wiki-inspired building blocks.
#
# This documentation is intended for developers who want to understand:
#
#   1. how ruby Card objects work, and
#   2. how to extend them.
#
# It assumes that you've already read the introductory text in {file:README.rdoc}.
#
# Throughout this document we will refer to @card as an instance of a Card object.
#
# ##Names
#
# There are four important card identifiers, sometimes called "marks".  Every card has a unique _name_, _key_, and _id_. Some cards also have a _codename_.
#
#       @card.name     # The name, a String, is the most recognizable card mark.
#       @card.key      # The key, a String, is a simple lower-case name variant.
#       @card.id       # The id is an Integer.
#       @card.codename # The codename, a Symbol, is the name by which a card can be referred to in code.
#
# All names with the same key (including the key itself) are considered variants of each other. No two cards can have names with the same key.
#
# `@card.cardname` refers to the same name as ``@card.name``, but it is a {Card::Name} object and has many additional methods.
#
# {Card::Codename More about codenames.}
#
# ## Fetching
#
# The two main ways to retrieve cards are fetching (retrieving cards one at a time) and querying (retrieving lists of cards).
#
# Any of the above marks (name, key, id, codename) can be used to fetch a card, eg:
#
#      @card = Card.fetch "Garden" # returns the card with the name "Garden" (or, more precisely, with the key "garden")
#      @card = Card.fetch 100      # returns the card with the id 100
#      @card = Card.fetch :help    # returns the card with the codename help
#
# The fetch API will first try to find the card in the cache and will only look in the database if necessary.
#
# {file:mod/core/set/all/fetch.rb More about fetching}
#
# ## Type
#
# Every card has a type, and every type itself has an associated card. For example, _Paula_'s type might be _User_, so there is also a _User_ card.
#
# The type may be accessed in several ways:
#
#       @card.type_card    # returns type card [Card]
#       @card.type_id      # returns id of type card [Integer]
#       @card.type_name    # returns name of type card [String]
#       @card.type_code    # returns codename of type card [Symbol]
#
# {file:mod/core/set/all/type.rb set module with type methods}
#
# ## Content
# chunks
#
# ## Query
# reference, query
#
# ## Accounts
# permission
#
#
# ## History
# acts, actions, changes
# subcards, act_manager
#
# ## Events
# mailer
#
# ## Caching

class Card < ApplicationRecord
  require_dependency "active_record/connection_adapters_ext"
  require_dependency "card/codename"
  require_dependency "card/query"
  require_dependency "card/format"
  require_dependency "card/error"
  require_dependency "card/auth"
  require_dependency "card/mod"
  require_dependency "card/content"
  require_dependency "card/action"
  require_dependency "card/act"
  require_dependency "card/change"
  require_dependency "card/reference"
  require_dependency "card/subcards"
  require_dependency "card/view"
  require_dependency "card/act_manager"

  has_many :references_in,  class_name: :Reference, foreign_key: :referee_id
  has_many :references_out, class_name: :Reference, foreign_key: :referer_id
  has_many :acts, -> { order :id }
  has_many :actions, -> { where(draft: [nil, false]).order :id }
  has_many :drafts, -> { where(draft: true).order :id }, class_name: :Action

  cattr_accessor :set_patterns, :serializable_attributes, :error_codes,
                 :set_specific_attributes, :current_act
  self.set_patterns = []
  self.error_codes = {}

  # attributes that ActiveJob can handle
  def self.serializable_attr_accessor *args
    self.serializable_attributes = args
    attr_accessor(*args)
  end

  serializable_attr_accessor(
    :action, :supercard, :superleft,
    :current_act, :current_action,
    :comment,                     # obviated soon
    :update_referers,             # wrong mechanism for this
    :update_all_users,            # if the above is wrong then this one too
    :silent_change,               # and this probably too
    :remove_rule_stash,
    :last_action_id_before_edit,
    :only_storage_phase,           # used to save subcards
    :changed_attributes
  )

  def serializable_attributes
    self.class.serializable_attributes + set_specific.keys
  end

  attr_accessor :follower_stash

  define_callbacks(
    :select_action, :show_page, :act,

    # VALIDATION PHASE
    :initialize_stage, :prepare_to_validate_stage, :validate_stage,
    :initialize_final_stage, :prepare_to_validate_final_stage,
    :validate_final_stage,

    # STORAGE PHASE
    :prepare_to_store_stage, :store_stage, :finalize_stage,
    :prepare_to_store_final_stage, :store_final_stage, :finalize_final_stage,

    # INTEGRATION PHASE
    :integrate_stage, :integrate_with_delay_stage,
    :integrate_final_stage,
    :after_integrate_stage,
    :after_integrate_final_stage, :integrate_with_delay_final_stage
  )

  # Validation and integration phase are only called for the act card
  # The act card starts those phases for all its subcards
  before_validation :validation_phase, unless: -> { only_storage_phase? }
  around_save :storage_phase
  after_commit :integration_phase, unless: -> { only_storage_phase? }
  after_rollback :clean_up, unless: -> { only_storage_phase? }

  extend CarrierWave::Mount
  ActiveSupport.run_load_hooks(:card, self)
end
