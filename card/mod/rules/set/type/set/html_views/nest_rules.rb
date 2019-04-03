format :html do
  view :nest_rules, cache: :never, tags: :unknown_ok, wrap: :slot do
    output [rules_filter(:field_related_rules, :self),
             quick_edit_rules_list(:field_related)]
  end

  def quick_edit_rules_list list
    list_tag class: "nav nav-pills flex-column bridge-pills" do
      setting_list(list).map do |setting|
        rules_list_item setting, :quick_edit
      end
    end
  end
end
