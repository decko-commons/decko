# format :html do
#   #### DEPRECATED
#
#   def rule_set_selection
#     wrap_with :div, class: "set-list" do
#       [rule_set_formgroup, related_set_formgroup]
#     end
#   end
#
#   def rule_set_formgroup
#     tag = @rule_context.rule_user_setting_name
#     narrower = []
#     option_list "Set" do
#       rule_set_options.map do |set_name, state|
#         rule_set_radio_button set_name, tag, state, narrower
#       end
#     end
#   end
#
#   def related_set_formgroup
#     related_sets = related_sets_in_context
#     return "" unless related_sets&.present?
#
#     tag = @rule_context.rule_user_setting_name
#     option_list "related set" do
#       related_rule_radios related_sets, tag
#     end
#   end
#
#   def related_sets_in_context
#     set_context = @rule_context.rule_set_name
#     set_context && Card.fetch(set_context).prototype.related_sets
#   end
#
#   def option_list title, &block
#     formgroup title, input: "set", class: "col-xs-6", help: false do
#       wrap_with :ul do
#         wrap_each_with(:li, class: "radio", &block)
#       end
#     end
#   end
#
#   def related_rule_radios related_sets, tag
#     related_sets.map do |set_name, _label|
#       rule_name = "#{set_name}+#{tag}"
#       state = Card.exists?(rule_name) ? :exists : nil
#       rule_radio set_name, state do
#         radio_button :name, rule_name
#       end
#     end
#   end
# end
