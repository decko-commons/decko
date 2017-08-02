# -*- encoding : utf-8 -*-
require "carrierwave"

Object.const_remove_if_defined :Card

# Cards are wiki-inspired building blocks.
#
# This documentation is intended for developers who want to understand:
#
# a. how ruby Card objects work, and
# b. how to extend them.
#
# It assumes that you've already read the introductory text
# in {file:README_Developers.rdoc}.
class Card < ApplicationRecord
  # attributes that ActiveJob can handle
  def self.serializable_attr_accessor *args
    self.serializable_attributes = args
    attr_accessor(*args)
  end

  require_dependency "active_record/connection_adapters_ext"
  require_dependency "card/codename"
  require_dependency "card/query"
  require_dependency "card/format"
  require_dependency "card/error"
  require_dependency "card/auth"
  require_dependency "card/mod/loader"
  require_dependency "card/content"
  require_dependency "card/action"
  require_dependency "card/act"
  require_dependency "card/change"
  require_dependency "card/reference"
  require_dependency "card/subcards"
  require_dependency "card/view"
  require_dependency "card/act_manager"
  require_dependency "card/act_manager/stage_director"

  has_many :references_in,  class_name: :Reference, foreign_key: :referee_id
  has_many :references_out, class_name: :Reference, foreign_key: :referer_id
  has_many :acts, -> { order :id }
  has_many :actions, -> { where(draft: [nil, false]).order :id }
  has_many :drafts, -> { where(draft: true).order :id }, class_name: :Action

  cattr_accessor :set_patterns, :serializable_attributes, :error_codes,
                 :set_specific_attributes, :current_act
  self.set_patterns = []
  self.error_codes = {}

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
