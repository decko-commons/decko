format :html do
  view :rule_link, unknown: true do
    rule_card = find_existing_rule_card
    wrap_closed_rule rule_card do
      %i[link set].map do |cell|
        send "closed_rule_#{cell}_cell", rule_card
      end
    end
  end

  view :rule_modal_link, unknown: true do
    rule_card = find_existing_rule_card
      wrap_closed_rule rule_card do
        %i[modal_link set].map do |cell|
          send "closed_rule_#{cell}_cell", rule_card
        end
      end
  end

  def wrap_closed_rule rule_card
    klass = rule_card&.real? ? "known-rule" : "table-active"
    wrap(true, { class: "closed-rule #{klass}" }, :tr) { yield }
  end

  def closed_rule_link_cell _rule_card
    wrap_rule_cell "rule-setting" do
      opts = bridge_link_opts(class: "edit-rule-link")
      opts[:path].delete(:layout)
      link_to_view :overlay_rule, setting_title, opts
    end
  end

  def closed_rule_modal_link_cell _rule_card
    wrap_rule_cell "rule-setting" do
      opts = bridge_link_opts(class: "edit-rule-link")
      opts[:path].delete(:layout)
      opts["data-modal-class"] = "modal-lg"
      link_to_view :modal_rule, setting_title, opts
    end
  end

  def closed_rule_setting_cell _rule_card
    wrap_rule_cell "rule-setting" do
      link_to_open_rule
    end
  end

  def closed_rule_content_cell rule_card
    wrap_rule_cell "rule-content" do
      rule_content_container { closed_rule_content rule_card }
    end
  end

  def closed_rule_set_cell rule_card
    wrap_rule_cell "rule-set d-none d-sm-table-cell" do
      rule_card ? rule_card.trunk.label : ""
    end
  end

  def wrap_rule_cell css_class
    wrap_with(:td, class: "rule-cell #{css_class}") { yield }
  end
end
