format :html do
  ###---( TOP_LEVEL (used by menu) NEW / EDIT VIEWS )
  view :edit, perms: :update, tags: :unknown_ok, cache: :never,
              bridge: true, wrap: :bridge do
    with_nest_mode :edit do
      voo.show :help
      wrap true, breadcrumb_data("Editing", "edit") do
        [
          _render_edit_name_row,
          _render_edit_type_row,
          frame_help,
          _render_edit_content_form
        ]
      end
    end
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
  view :just_deleted, tag: :unknown_ok do
    wrap { "#{render_title} deleted" }
  end

  view :edit_rules, cache: :never, tags: :unknown_ok do
    voo.show :set_navbar
    voo.hide :set_label, :rule_navbar, :toolbar

    render_related items: { nest_name: current_set_card.name, view: :bridge_rules_tab }
  end

  view :edit_structure, cache: :never do
    return unless card.structure

    voo.show :toolbar
    render_related items: { view: :edit, nest_name: card.structure_rule_card.name }
    # FIXME: this stuff:
    #  slot: {
    #    cancel_slot_selector: ".card-slot.related-view",
    #    cancel_path: card.format.path(view: :edit), hide: :edit_toolbar,
    #    hidden: { success: { view: :open, "slot[subframe]" => true } }
    #  }
    # }
  end

  view :edit_nests, cache: :never do
    voo.show :toolbar
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
  #   voo.show :toolbar
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
