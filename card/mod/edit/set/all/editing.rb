format :html do
  ###---( TOP_LEVEL (used by menu) NEW / EDIT VIEWS )
  view :edit, perms: :update, tags: :unknown_ok, cache: :never,
              bridge: true,
              wrap: :bridge do
    with_nest_mode :edit do
      voo.show :help
      wrap true, "data-breadcrumb": "Editing" do
        card_form :update, edit_form_opts do
          [
            _render_edit_name_row,
            _render_edit_type_row,
            edit_view_hidden,
            _render_content_formgroup,
            _render_edit_buttons
          ]
        end
      end
    end
  end

  view :edit_in_place, perms: :update, tags: :unknown_ok, cache: :never, wrap: :slot do
    with_nest_mode :edit do
      card_form :update, edit_form_opts do
        [
          edit_view_hidden,
          _render_content_formgroup,
          _render_edit_buttons
        ]
      end
    end
  end

  def edit_form_opts
    # for override
    {}
  end

  def edit_view_hidden
    # for override
  end

  view :edit_name_row do
    edit_row "Name", card.name, :edit_name_form
  end

  view :edit_type_row do
    edit_row "Type", link_to_card(card.type), :edit_type_form
  end

  def edit_row title, content, edit_view
    class_up "card-slot", "d-flex"
    link =
      link_to_view(edit_view, fa_icon(:edit), class: "ml-auto edit-link slotter")

    wrap class: "d-flex" do
      ["<label class='w-50px'>#{title}</label>",
       content,
       link]
    end
  end

  view :edit_buttons do
    button_formgroup do
      wrap_with "div", class: "d-flex" do
        [standard_submit_button, edit_cancel_button, delete_button]
      end
    end
  end

  def standard_submit_button
    modal_submit_button(class: "submit-button btn-sm mr-3", text: "Save") + submit_button(class: "submit-button btn-sm mr-3", text: "Save and Close")
  end


  def edit_cancel_button
    modal_close_button "Cancel", situation: "secondary", class: "btn-sm ml-4"
  end

  def standard_cancel_button args={}
    args.reverse_merge! class: "cancel-button ml-4", href: path
    cancel_button args
  end

  def delete_button
    confirm = "Are you sure you want to delete #{safe_name}?"
    success = main? ? "REDIRECT: *previous" : { view: :just_deleted }
    link_to "Delete",
            path: { action: :delete, success: success },
            class: "slotter btn btn-outline-danger ml-auto btn-sm", remote: true, 'data-confirm': confirm
  end

  # TODO: add undo functionality
  view :just_deleted, tag: :unknown_ok do
    wrap { "#{render_title} deleted" }
  end

  view :edit_type, cache: :never, perms: :update do
    frame do
      _render_edit_type_form
    end
  end

  view :edit_type_form, cache: :never, perms: :update do
    card_form :update do
      output [hidden_edit_type_fields,
              _render_type_formgroup,
              edit_type_buttons]
    end
  end

  def hidden_edit_type_fields
    hidden_field_tag "success[view]", "edit"
  end

  def edit_type_buttons
    cancel_path = path view: :edit
    button_formgroup do
      [standard_submit_button, standard_cancel_button(href: cancel_path)]
    end
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
