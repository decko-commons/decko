format :html do
  ###---( TOP_LEVEL (used by menu) NEW / EDIT VIEWS )
  view :bridge, perms: :update, unknown: true, cache: :never, wrap: :bridge do
    with_nest_mode :edit do
      add_name_context
      voo.show :help
      wrap true, breadcrumb_data("Editing", "edit") do
        bridge_parts
      end
    end
  end

  view :cardboard, :bridge

  def bridge_parts
    voo.show! :edit_type_row

    [
      frame_help,
      _render_edit_name_row(home_view: :edit_name_row),
      # home_view is necessary for cancel to work correctly.
      # it seems a little strange to have to think about home_view here,
      # but the issue is that something currently has to happen prior to the
      # render to get voo.slot_options to have the write home view in
      # the slot wrap. I think this would probably best be handled as an
      # option to #wrap that triggers a new heir voo
      _render_edit_form
    ]
  end

  def edit_success
    # for override
  end

  def edit_view_hidden
    # for override
  end

  view :edit_buttons do
    button_formgroup do
      wrap_with "div", class: "d-flex" do
        [standard_submit_button, edit_cancel_button, delete_button]
      end
    end
  end

  # TODO: add undo functionality
  view :just_deleted, unknown: true do
    wrap { "#{render_title} deleted" }
  end

  view :edit_rules, cache: :never, unknown: true do
    nest current_set_card, view: :bridge_rules_tab
  end

  view :edit_structure, cache: :never do
    return unless card.structure

    nest card.structure_rule_card, view: :edit
    # FIXME: this stuff:
    #  slot: {
    #    cancel_slot_selector: ".card-slot.related-view",
    #    cancel_path: card.format.path(view: :edit), hide: :edit_toolbar,
    #    hidden: { success: { view: :open, "slot[subframe]" => true } }
    #  }
    # }
  end

  view :edit_nests, cache: :never do
    frame do
      with_nest_mode :edit do
        multi_card_edit
      end
    end
  end

  # FIXME: - view can recurse.  temporarily turned off
  #
  # view :edit_nest_rules, cache: :never do
  #   return ""#
  #   view = args[:rule_view] || :field_related_rules
  #   frame do
  #     # with_nest_mode :edit do
  #     nested_fields.map do |name, _options|
  #       nest Card.fetch(name.to_name.trait(:self)),
  #            view: :titled, title: name, rule_view: view,
  #            hide: :set_label, show: :rule_navbar
  #     end
  #   end
  # end
end
