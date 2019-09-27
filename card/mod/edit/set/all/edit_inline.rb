format :html do
  view :edit_inline, perms: :update, unknown: true, cache: :never, wrap: :slot do
    voo.hide :name_formgroup, :type_formgroup
    with_nest_mode :edit do
      card_form :update, success: edit_success do
        [
          edit_view_hidden,
          _render_content_formgroups,
          _render_edit_inline_buttons
        ]
      end
    end
  end

  view :edit_name_row do
    edit_row_fixed_width "Name", card.name, :name_form
  end

  view :edit_inline_buttons do
    button_formgroup do
      wrap_with "div", class: "d-flex" do
        [standard_save_button, cancel_in_place_button, delete_button]
      end
    end
  end

  # TODO: better styling for this so that is reusable
  #  At the moment it is used for the name and type field in the bridge
  #  (with fixed 50px width for the title column) and
  #  for password and email for accounts (with fixed 75px width for the title column)
  #  The view is very similar to labeled but with fixed edit link on the right
  #  and a fixed width for the labels so that the content column is aligned
  #  There is also the problem that label and content are not vertically aligned
  view :edit_row do
    edit_row_fixed_width render_title, render_core, :edit_inline, 75
  end

  def edit_row_fixed_width title, content, edit_view, width=50
    class_up "card-slot", "d-flex"
    wrap do
      ["<label class='w-#{width}px'>#{title}</label>",
       content,
       edit_inline_link(edit_view, align: :right)]
    end
  end

  def edit_inline_link view=:edit_inline, align: :left
    align = align == :left ? "ml-2" : "ml-auto"
    link_to_view view, menu_icon, class: "#{align} edit-link", "data-cy": "edit-link"
  end

  def cancel_in_place_button args={}
    args.reverse_merge! class: "cancel-button btn-sm", href: path
    cancel_button args
  end
end
