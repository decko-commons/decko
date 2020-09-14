# -*- encoding : utf-8 -*-

ActiveSupport.run_load_hooks(:before_card, self)

# Cards are wiki-inspired building blocks.
#
# This documentation is for developers who want to understand:
#
#   1. how ruby Card objects work, and
#   2. how to extend them.
#
# It assumes that you've already read the introductory text in {file:README.rdoc}.
#
# Throughout this document we will refer to @card as an instance of a Card object.
#
# ## Names
#
# There are four important card identifiers, sometimes called "marks".  Every card has a unique _name_, _key_, and _id_. Some cards also have a _codename_.
#
#       @card.name     # The name, a {Card::Name} object, is the most recognizable card mark.
#       @card.key      # The key, a String, is a simple lower-case name variant.
#       @card.id       # The id is an Integer.
#       @card.codename # The codename, a Symbol, is the name by which a card can be referred to in code.
#
# All names with the same key (including the key itself) are considered variants of each other. No two cards can have names with the same key. Card::Name objects inherit from Strings but add many other methods for common card name patterns, eg `"A+B".to_name.right => "B"`.
#
# Setting a card's name, eg `@card.name = "New Name"`, will automatically update the key.  {Card::Name More on names.}
#
# {Card::Codename More on codenames.}
#
# ## Type
#
# Every card has a type, and every type itself has an associated card. For example, _Paula_'s type might be _User_, so there is also a _User_ card.
#
# The type may be accessed in several ways:
#
#       @card.type_id      # returns id of type card [Integer]
#       @card.type_name    # returns name of type card [Card::Name]
#       @card.type_code    # returns codename of type card [Symbol]
#       @card.type_card    # returns Cardtype card associated with @card's type [Card]
#
# {file:mod/core/set/all/type.rb Common type methods}
#
# ## Content
#
# There are two primary methods for accessing a card's content:
#
#       @card.db_content   # the content as it appears in the database
#       @card.content      # the "official" content, which may be different from db_content when db_content is overridden with a structure rule.
#
# {Card::Content Processing card content}
#
# {file:mod/core/set/all/content.rb Common content methods}
#
# ## Fetch
#
# The two main ways to retrieve cards are fetching (retrieving cards one at a time) and querying (retrieving lists of cards). More on querying below.
#
# Any of the above marks (name, key, id, codename) can be used to fetch a card, eg:
#
#      @card = Card.fetch "Garden" # returns the card with the name "Garden" (or, more precisely, with the key "garden")
#      @card = Card.fetch 100      # returns the card with the id 100
#      @card = Card.fetch :help    # returns the card with the codename help
#
# The fetch API will first try to find the card in the cache and will only look in the database if necessary.
#
# {file:mod/core/set/all/fetch.rb More on fetching.}
#
# ## Query
#
# Card queries find and return lists of cards, eg:
#
#       Card.search type_id: 4 # returns an Array of cards with the type_id of 4.
#
# {Card::Query More on queries}
#
# ## Views and Events
#
# Views and events are a _Decker's_ primary tools for manipulating cards. Views customize card presentation, while events customize card transactions. Or, if you like, views and events respectively alter cards in _space_ and _time_.
#
# Both views and events are defined in {Card::Mod mods}, short for modules or modifications.
#
# {Card::Set::Format::AbstractFormat More on views}
#
# {Card::Set::Event::Api More on events}
#
# ## Accounts and Permissions
#
# Card code is always executed in the context of a given user account. Permissions for that account are automatically checked when running a query, performing an action, or rendering a view.  A typical query, for example, can only return cards that the current user has permission to read.
#
# You can see the current user with `Card::Auth.current`. The permissions of a proxy user can be temporarily assumed using `Card::Auth#as`.
#
# {Card::Auth More on accounts}
class Card < ApplicationRecord
  extend Mark
  extend Dirty::MethodFactory
  include Dirty
  include DirtyNames
  include Director::CardMethods

  Card::Cache # trigger autoload

  has_many :references_in,  class_name: :Reference, foreign_key: :referee_id
  has_many :references_out, class_name: :Reference, foreign_key: :referer_id
  has_many :acts, -> { order :id }
  has_many :actions, -> { where(draft: [nil, false]).order :id }
  has_many :drafts, -> { where(draft: true).order :id }, class_name: :Action

  cattr_accessor :set_patterns, :action_specific_attributes, :set_specific_attributes

  self.set_patterns = []
  self.action_specific_attributes = [
    :supercard,
    :superleft,
    :action,
    :current_action,
    :last_action_id_before_edit,

    :skip,                        # skip event(s) for all cards in act
    :skip_in_action,              # skip event for just this card
    :trigger,                     # trigger event(s) for all cards in act
    :trigger_in_action,           # trigger event for just this card

    :comment,                     # obviated soon

    # TODO: refactor following to use skip/trigger
    :update_referers,             # wrong mechanism for this
    :update_all_users,            # if the above is wrong then this one too
    :silent_change                # and this probably too
  ]

  attr_accessor(*action_specific_attributes)

  define_callbacks :select_action, :show_page, :act

  ActiveSupport.run_load_hooks :card, self
end
ActiveSupport.run_load_hooks :after_card, self
