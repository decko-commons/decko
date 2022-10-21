# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Rule::Editor do
  def card_subject
    Card.fetch("*read+*right+*input type", new: {})
  end

  check_views_for_errors

  describe "#left_type_for_nest_editor_set_selection" do
    def type_for_set_structure set_name
      Card.fetch("#{set_name}+*structure").left_type_for_nest_editor_set_selection
    end

    it "finds anchor name for type structure rules" do
      expect(type_for_set_structure("Role+*type")).to eq("Role")
    end

    it "finds anchor type for self structure rules" do
      expect(type_for_set_structure("Sign up+*self")).to eq("Cardtype")
    end
  end
end
