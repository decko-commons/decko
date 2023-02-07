# -*- encoding : utf-8 -*-

class Card
  # A _Set_ is a group of {Card Cards} to which _Rules_ may apply. Sets can be as
  # specific as a single card, as general as all cards, or anywhere in between.
  #
  # Rules can defined onto Sets in two ways:
  #
  #  - **Card rules** are defined in card content. These are generally configured via the
  # web interface and are thus documented at https://decko.org/rules.
  #  - **Code rules** can be defined in a 'set module'.
  #
  # ## Set Modules
  #
  # ### File structure
  #
  # Set modules specify views, events, and other methods for a given set of cards.
  # They are defined in a {Cardio::Mod mod's} _set_ directory. For example, suppose
  # you've created a mod called *biz*, your deck has Company cards, and you want to
  # extend the behavior of those cards.
  #
  # You can add a set module like so:
  #
  #       card generate set biz type company
  #
  # This will create the following two files:
  #
  #       mod/biz/set/type/company.rb
  #       mod/biz/spec/set/type/company.rb
  #
  # If you would like to break this code into smaller files, you can extend this
  # pattern into another directory, eg:
  #
  #       mod/biz/set/type/company/foo.rb
  #       mod/biz/set/type/company/bar.rb
  #
  # The general pattern can be expressed as follows:
  #
  #       DECKNAME/mod/MODNAME/set/SET_PATTERN/ANCHOR[/FREENAME].rb
  #
  # **Note:** _the set module's filename connects it to the set, so both the set_pattern
  # and the set_anchor must correspond to the codename of a card in the database to
  # function correctly. For example, the type/company directory corresponds to the Set
  # card named `:company+:type`. Both the :company and :type codenames must exist for this
  # to work properly._
  #
  # ### Writing/Editing set modules
  #
  #  A set module is mostly standard ruby, but the files are quite concise because
  #
  #   1. the set module's file location is used to autogenerate ruby module definitions
  #   2. A DSL (Domain-Specific Language) makes common tasks easy.
  #
  # You can, for example, edit `mod/biz/set/type/company.rb`, and add _only_ the
  # following code:
  #
  #     def hello
  #       "world"
  #     end
  #
  # No further code is needed for this method to be available to cards with the type
  # Company (as specified by the file's location). This code will automatically be added
  # to a ruby module named `Card::Set::Type::Company`. That module is extended with the
  # {Card::Set} module, giving it access to the set module DSL.
  #
  # These important Card::Set subclasses explain more about the DSL
  #
  #   - {Format} introduces format blocks
  #   - {Format::AbstractFormat} covers {Format::AbstractFormat#view view} definitions
  #   - {Event::Api} explains {Event::Api#event event} definitions
  #
  # ### Loading set modules
  #
  # Whenever you fetch or instantiate a card, the card will automatically
  # include code from all the set modules associated with sets of which it is a member.
  #
  #  For example, say you have a Plaintext card named 'Philipp+address', and you have set
  # files for the following sets:
  #
  #   * all cards
  #   * all Plaintext cards
  #   * all cards ending in +address
  #
  #  When you run any of these:
  #
  #      mycard = Card.fetch "Philipp+address"
  #      mycard = "Philipp+address".card
  #      mycard = ["Philipp", "address"].card
  #
  #  ...then mycard will include the set modules associated with each of those sets in the
  # above order.
  #
  #
  module Set
    include Event::Api
    include Trait
    include Inheritance

    include Format
    include AdvancedApi
    include Helpers

    extend I18nScope
    extend Registrar

    class << self
      attr_accessor :modules, :traits, :basket

      def reset
        self.modules = {
          base: [],     base_format: {},
          nonbase: {},  nonbase_format: {},
          abstract: {}, abstract_format: {}
        }

        self.basket = {}
      end
    end

    delegate :basket, to: Set

    reset

    # SET MODULE API
    #
    # The most important parts of the set module API are views (see
    # Card::Set::Format) and events (see Card::Set::Event:Api)
  end
end
