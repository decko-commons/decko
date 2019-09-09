# -*- encoding : utf-8 -*-

class AddCardtypeInputTypes < Card::Migration::Core
  def up
    ensure_input_types pointer: %w[select radio autocomplete],
                       list: ["multiselect", "checkbox", "filtered list",
                              "autocompleted list"],
                       plain_text: ["text area", "text field", "ace editor"]
  end

  def ensure_input_types hash
    # hash.each do |cardtype, input_types|
    #   ensure_card [cardtype, :input_type, :type_plus_right],
    #               type_id: Card::ListID,
    #               content: input_types
    #   end
  end
end
