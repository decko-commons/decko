# LOCALIZE first item
TOGGLE_MAP = { close: %w[open open], open: %w[close closed] }.freeze

format :html do
  view :header, perms: :none do
    header_wrap [render_header_title, render_menu]
  end

  def header_wrap header_parts
    wrap_with :div, class: classy("d0-card-header") do
      output Array.wrap(header_parts)
    end
  end

  view :header_title, perms: :none do
    wrap_with (voo.header || :h2), class: classy("d0-card-header-title") do
      render_title
    end
  end

  def show_draft_link?
    card.drafts.present? && @slot_view == :edit
  end

  def structure_editable?
    card.structure && card.template.ok?(:update)
  end
end
