format :html do
  view :open_rule, cache: :never, tags: :unknown_ok,
                   wrap: { modal: { size: :large,
                                    title: :edit_rule_title,
                                    footer: "" } } do
    current_rule_form success_view: :rule_row, form_type: :modal
  end

  def edit_rule_title
    output [
      wrap_with(:h5, setting_title, class: "title font-weight-bold"),
      render_overlay_rule_help
    ]
  end

  # used in tables shown in set cards' core view
  view :rule_row, cache: :never, tags: :unknown_ok do
    rule_card = find_existing_rule_card
    cols = %i[setting set]
    cols.insert(1, :content) if voo.show? :content
    wrap_closed_rule rule_card do
      cols.map do |cell|
        send "closed_rule_#{cell}_cell", rule_card
      end
    end
  end
end
