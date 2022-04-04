# -*- encoding : utf-8 -*-

require "active_support/core_ext/numeric/time"

# noinspection RubyResolve
class SharedData
  extend Card::Model::SaveHelper

  CARDTYPE_COUNT = 44

  USERS = [
    "Joe Admin", "Joe User", "Joe Camel", "Sample User", "No count",
    "u1", "u2", "u3",
    "Big Brother", "Optic fan", "Sunglasses fan", "Narcissist"
  ].freeze

  class << self
    # noinspection RubyResolve
    def add_test_data
      Card::Cache.reset_all
      Card::Env.reset
      Card::Auth.as_bot

      cardtype_cards

      # for template stuff
      create "UserForm+*type+*structure", "{{+name}} {{+age}} {{+description}}"

      Card::Auth.signin "joe_user"
      create "JoeLater", "test"
      create "JoeNow", "test"

      Card::Auth.signin Card::WagnBotID

      create "Book+*type+*structure", "by {{+author}}, design by {{+illustrator}}"
      create_book "Iliad"

      create_author "Darles Chickens"
      create_author "Stam Broker"
      create_book "Parry Hotter"
      create_book "50 grades of shy"

      ## --------- Fruit: creatable by anyone but not readable ---
      Card.create! name: "Fruit+*type+*create", type: "Pointer", content: "[[Anyone]]"
      Card.create! name: "Fruit+*type+*read", type: "Pointer",
                   content: "[[Administrator]]"

      # codenames for card_accessor tests
      Card.create! name: "*write", codename: :write

      # -------- For history testing: -----------
      first = create "First", "egg"
      first.update! content: "chicken"
      first.update! content: "chick"

      # -------- For rename testing: -----------
      [
        ["Blue", ""],
        ["blue includer 1", "{{Blue}}"],
        ["blue includer 2", "{{blue|closed;other:stuff}}"],
        ["blue linker 1", "[[Blue]]"],
        ["blue linker 2", "[[blue]]"]
      ].each do |name, content|
        create name, content
      end

      notification_cards

      create "42", TEXT
      create_pointer "items",
                     content: ["Parry Hotter", "42", "Stam Broker", "First",
                               "yeti skin+image", "*all+*script+*machine output"]
    end

    def cardtype_cards
      # for cql & permissions
      %w[A+C A+D A+E C+A D+A F+A A+B+C].each { |name| create name }

      ("a".."f").each do |ch|
        create "type-#{ch}-card", type_code: "cardtype_#{ch}",
                                  content: "type_#{ch}_content"
      end

      create_pointer "Cardtype B+*type+*create", "[[r3]]"
      create_pointer "Cardtype B+*type+*update", "[[r1]]"

      ## --------- create templated permissions -------------
      create "Cardtype E+*type+*default"
    end

    def notification_cards
      # fwiw Timecop is apparently limited by ruby Time object,
      # which goes only to 2037 and back to 1900 or so.
      #  whereas DateTime can represent all dates.

      followers = {
        "John" => ["John Following", "All Eyes On Me"],
        "Sara" => ["Sara Following", "All Eyes On Me", "Optic+*type",
                   "Google Glass"],
        "Big Brother" => ["All Eyes on Me", "Look at me+*self", "Optic+*type",
                          "lens+*right", "Optic+tint+*type plus right",
                          ["*all", "*created"], ["*all", "*edited"]],
        "Optic fan" => ["Optic+*type"],
        "Sunglasses fan" => ["Sunglasses"],
        "Narcissist" => [["*all", "*created"], ["*all", "*edited"]]
      }

      create "All Eyes On Me"
      create "No One Sees Me"
      create "Look At Me"
      create_cardtype "Optic"
      create "Sara Following"
      create "John Following", "{{+her}}"
      create "John Following+her"
      magnifier = create "Magnifier+lens"

      Card::Auth.signin "Narcissist"
      magnifier.update! content: "zoom in"
      create_optic "Sunglasses", "{{+tint}}{{+lens}}"

      Card::Auth.signin "Optic fan"
      create_optic "Google glass", "{{+price}}"

      Card::Auth.signin Card::WagnBotID
      create "Google glass+*self+*follow_fields", ""
      create "Sunglasses+*self+*follow_fields",
             "[[#{:nests.cardname}]]\n[[_self+price]]\n[[_self+producer]]"
      create "Sunglasses+tint"
      create "Sunglasses+price"

      followers.each do |name, follow|
        user = Card[name]
        follow.each do |f|
          user.follow(*f)
        end
      end

      # capitalized names so that they don't interfere with checks for the verbs
      create "Created card", content: "new content"
      update "Created card", name: "Updated card", content: "changed content",
                             type: :pointer, skip: :validate_renaming
      create "Created card", content: "new content"
      card = create "Deleted card", content: "old content"
      card.delete

      Card::Auth.with "Joe User" do
        [
          ["card with fields", "field 1", "field 2"],
          ["card with fields and admin fields", "field 1", "admin field 1"],
          ["admin card with fields and admin fields", "field 1", "admin field 1"],
          ["admin card with admin fields", "admin field 1", "admin field 2"]
        ].each do |name, f1, f2|
          create name,
                 content: "main content {{+#{f1}}}  {{+#{f2}}}",
                 subcards: { "+#{f1}" => "content of #{f1}",
                             "+#{f2}" => "content of #{f2}" }
        end
      end

      Card::Auth.as_bot do
        [
          ["admin card with fields and admin fields", :self],
          ["admin card with admin fields", :self],
          ["admin field 1", :right],
          ["admin field 2", :right]
        ].each do |name, rule_set|
          create [name, rule_set, :read], type: "Pointer", content: "[[Administrator]]"
        end
        create ["field 1", :right, :read], type: "Pointer", content: "[[Anyone]]"
      end
    end
  end

  TEXT = <<~TXT.strip_heredoc.freeze
          Far out in the uncharted backwaters of the unfashionable end of
          the western spiral arm of the Galaxy lies a small unregarded
          yellow sun.
          
          Orbiting this at a distance of roughly ninety-two million miles
          is an utterly insignificant little blue green planet whose ape-
          descended life forms are so amazingly primitive that they still
          think digital watches are a pretty neat idea.
          
          This planet has - or rather had - a problem, which was this: most
          of the people living on it were unhappy for pretty much of the time.
          Many solutions were suggested for this problem, but most of these
          were largely concerned with the movements of small green pieces
          of paper, which is odd because on the whole it wasn't the small
          green pieces of paper that were unhappy.
  TXT
end
