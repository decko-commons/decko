# -*- encoding : utf-8 -*-

require "active_support/core_ext/numeric/time"

# noinspection RubyResolve
class SharedData
  extend Card::Model::SaveHelper

  class << self
    # noinspection RubyResolve
    def add_test_data
      Card::Cache.reset_all
      Card::Env.reset
      Card::Auth.as_bot

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
end
