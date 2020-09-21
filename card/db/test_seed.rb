# -*- encoding : utf-8 -*-

require "timecop"

# noinspection RubyResolve
class SharedData
  extend Card::Model::SaveHelper

  USERS = [
    "Joe Admin", "Joe User", "Joe Camel", "Sample User", "No count",
    "u1", "u2", "u3",
    "Big Brother", "Optic fan", "Sunglasses fan", "Narcissist"
  ].freeze

  CARDTYPE_COUNT = 42

  class << self

    def create_user name, args
      args[:subcards] = account_args args if args[:email]

      if name == "Joe Admin"
        super name, args
      else
        Card::Auth.with("joe_admin") { super name, args }
      end
    end

    def account_args hash
      { "+*account" => { "+*email" => hash.delete(:email),
                         "+*password" => hash.delete(:password) || "joe_pass" } }
    end

    # noinspection RubyResolve
    def add_test_data
      Card::Cache.reset_all
      Card::Env.reset
      Card::Auth.as_bot

      user_and_role_cards

      # generic, shared attribute card
      ensure_card "color"

      create "signup alert email+*to", "signups@wagn.org"
      # CREATE A CARD OF EACH TYPE

      no_samples = %w[user sign_up set number mirror_list mirrored_list file image
                      customized_bootswatch_skin]
      Card::Auth.createable_types.each do |type|
        next if no_samples.include? type.to_name.key
        create type: type, name: "Sample #{type}"
      end

      %w[c1 c2 c3].each do |name|
        create name
      end

      create_layout_type "lay out", "Greatest {{_main|title: Callahan!; view: labeled}}"
      create_pointer "stacks", ["horizontal", "vertical"]
      create_pointer "stacks+*self+*layout", "lay out"
      create "horizontal"
      create_pointer "vertical"

      create_pointer "friends+*right+*default"
      create_search_type "friends+*right+*content options", '{"type":"User"}'

      create_pointer "joes"
      create "joes+*self+*input type", "filtered list"
      create "joes+*self+*content options", ["Joe Admin", "Joe User", "Joe Camel"]

      # cards for rename_test
      # FIXME: could probably refactor these..
      [
        ["Z", "I'm here to be referenced to"],
        ["A", "Alpha [[Z]]"],
        ["B", "Beta {{Z}}"],
        ["T", "Theta"],
        ["X", "[[A]] [[A+B]] [[T]]"],
        ["Y", "{{B}} {{A+B}} {{A}} {{T}}"],
        ["A+B", "AlphaBeta"],
        ["A+B+Y+Z", "more letters"],
        ["Link to unknown", "[[Mister X]]"]
      ].each do |name, content|
        create name, content
      end

      create "One+Two+Three"
      create "Four+One+Five"
      create "basicname", "basiccontent"

      cardtype_cards

      # for template stuff
      Card.create! type_id: Card::CardtypeID, name: "UserForm"
      create "UserForm+*type+*structure", "{{+name}} {{+age}} {{+description}}"

      Card::Auth.signin "joe_user"
      create "JoeLater", "test"
      create "JoeNow", "test"

      Card::Auth.signin Card::WagnBotID

      create_cardtype "Book"
      create "Book+*type+*structure", "by {{+author}}, design by {{+illustrator}}"
      create_book "Iliad"

      create_cardtype "Author"
      create_author "Darles Chickens"
      create_author "Stam Broker"
      create_book "Parry Hotter"
      create_book "50 grades of shy"

      ## --------- Fruit: creatable by anyone but not readable ---
      Card.create! type: "Cardtype", name: "Fruit"
      Card.create! name: "Fruit+*type+*create", type: "Pointer", content: "[[Anyone]]"
      Card.create! name: "Fruit+*type+*read", type: "Pointer", content: "[[Administrator]]"

      # codenames for card_accessor tests
      Card.create! name: "*write", codename: :write

      # -------- For toc testing: ------------

      create "OnneHeading", "<h1>This is one heading</h1>\r\n<p>and some text</p>"
      create "TwwoHeading", "<h1>One Heading</h1>\r\n<p>and some text</p>\r\n"\
                            "<h2>And a Subheading</h2>\r\n<p>and more text</p>"
      create "ThreeHeading", "<h1>A Heading</h1>\r\n<p>and text</p>\r\n"\
                             "<h2>And Subhead</h2>\r\n<p>text</p>\r\n"\
                             "<h1>And another top Heading</h1>"

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
      create_cardtype "self aware", "[[/new/{{_self|name}}|new]]"

      notification_cards

      create "42", TEXT
      create_pointer "items",
                     content: ["Parry Hotter", "42", "Stam Broker", "First",
                               "yeti skin+image", "*all+*script+*machine output"]
      # Card['*all+*style' ].ensure_machine_output
      # Card['*all+*script'].ensure_machine_output
      # (ie9 = Card[:script_html5shiv_printshiv]) && ie9.ensure_machine_output
    end

    def user_and_role_cards
      Card::Auth.instant_account_activation do
        create_user "Joe Admin", content: "I'm number one", email: "joe@admin.com"
        create_user "Joe User", content: "I'm number two", email: "joe@user.com"
        create_user "Joe Camel", content: "Mr. Buttz", email: "joe@camel.com"

        # data for testing users and account requests
        create_user "No Count", content: "I got no account"
        create_user "Sample User", email: "sample@user.com", password: "sample_pass"
      end

      # noinspection RubyResolve
      Card["Joe Admin"].fetch(:roles, new: { type_code: "pointer" })
        .items = [Card::AdministratorID, Card::SharkID, Card::HelpDeskID]

      Card["Joe User"].fetch(:roles, new: { type_code: "pointer" })
              .items = [Card::SharkID]

      create_user "u1", email: "u1@user.com", password: "u1_pass"
      create_user "u2", email: "u2@user.com", password: "u2_pass"
      create_user "u3", email: "u3@user.com", password: "u3_pass"

      r1 = create_role "r1"
      r2 = create_role "r2"
      r3 = create_role "r3"
      r4 = create_role "r4"

      Card["u1"].fetch(:roles, new: { type_code: "pointer" }).items = [r1, r2, r3]
      Card["u2"].fetch(:roles, new: {}).items = [r1, r2, r4]
      Card["u3"].fetch(:roles, new: {}).items = [r1, r4, Card::AdministratorID]
    end


    def cardtype_cards
      # for cql & permissions
      %w[A+C A+D A+E C+A D+A F+A A+B+C].each {|name| create name}
      ("A".."F").each do |ch|
        create "Cardtype #{ch}", type_code: "cardtype",
               codename: "cardtype_#{ch.downcase}"
      end
      Card::Codename.reset_cache

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
      Timecop.freeze(Cardio.future_stamp - 1.day) do
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

        followers.each do |name, _follow|
          create_user name, email: "#{name.parameterize}@user.com",
                      password: "#{name.parameterize}_pass"
        end

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
        create "Sunglasses+*self+*follow_fields", "[[#{:nests.cardname}]]\n[[_self+price]]\n[[_self+producer]]"
        create "Sunglasses+tint"
        create "Sunglasses+price"

        followers.each do |name, follow|
          user = Card[name]
          follow.each do |f|
            user.follow(*f)
          end
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
          ["admin card with admin fields", "admin field 1", "admin field 2"],
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

  TEXT = <<-TXT.strip_heredoc.freeze
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
