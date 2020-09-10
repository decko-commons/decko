# -*- encoding : utf-8 -*-

class Card
  #
  # A _Set_ is a group of {Card Cards} to which _Rules_ may apply. Sets can be as
  # specific as a single card, as general as all cards, or anywhere in between.
  #
  # Rules can defined onto Sets in two ways:
  #
  #  - **Card rules** are defined in card content. These are generally configured via the
  # web interface and are thus documented at https://decko.org/rules.
  #  - **Code rules** can be defined in a 'set module'.
  #
  # The {Card::Mod} docs explain how to create mods and set_modules. This page explains
  # how those modules become useful.
  #
  # Suppose you have created a "mod" for managing your contacts called "contactmanager",
  # and it includes code that would apply to all +address cards here:
  #
  #      ./contactmanager/set/right/address.rb
  #
  # Then, whenever you fetch or instantiate a +address card, the card will automatically
  # include code from that set module.  In fact, it will include all the set modules
  # associated with sets of which it is a member.
  #
  #  For example, say you have a Plaintext card named 'Philipp+address', and you have set
  # files for the following sets:
  #
  #      * all cards
  #      * all Plaintext cards
  #      * all cards ending in +address
  #
  #  When you run this:
  #
  #      mycard = Card.fetch 'Philipp+address'
  #
  #  ...then mycard will include the set modules associated with each of those sets in the
  # above order.
  #
  #  Note that the set module's filename connects it to the set, so both the set_pattern
  # and the set_anchor must correspond to the codename of a card in the database to
  # function correctly.
  #
  #  A set module is "just ruby", but is generally quite concise because Card uses
  #        a) the set module's file location to autogenerate ruby module names and
  #        b) Card::Set to provide API for the most common set methods.
  #
  module Set
    require "card/set/event"
    require "card/set/trait"
    require "card/set/basket"
    require "card/set/inheritance"
    require "card/set/format"
    require "card/set/advanced_api"
    require "card/set/helpers"
    require "card/set/i18n_scope"
    require "card/set/loader"

    include Event::Api
    include Trait
    include Basket
    include Inheritance

    include Format
    include AdvancedApi
    include Helpers

    extend I18nScope
    extend Loader

    mattr_accessor :modules, :traits

    def self.reset_modules
      self.modules = { base: [], base_format: {}, nonbase: {}, nonbase_format: {},
                       abstract: {}, abstract_format: {} }
    end

    reset_modules

    # SET MODULE API
    #
    # The most important parts of the set module API are views (see
    # Card::Set::Format) and events (see Card::Set::Event:Api)
  end
end
