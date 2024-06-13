BOARD_TABS = { "Account" => :account_tab,
               "Guide" => :guide_tab,
               "Engage" => :engage_tab,
               "History" => :history_tab,
               "Related" => :related_tab,
               "Rules" => :rules_tab }.freeze

BOARD_TAB_NAMES = BOARD_TABS.invert.freeze

format :html do
  wrapper :board do
    class_up "modal-dialog", "no-gaps"
    voo.hide! :modal_footer
    wrap_with_modal(size: :full,
                    title: board_breadcrumbs,
                    menu: :board_menu) do
      haml :board
    end
  end

  def board_tabs
    wrap do
      tabs(visible_board_tabs, BOARD_TAB_NAMES[board_tab], load: :lazy) do
        _render board_tab
      end
    end
  end

  def board_tab
    @board_tab ||= board_param :tab
  end

  def board_param key
    params.dig(:board, key)&.to_sym || try("default_board_#{key}")
  end

  def board_breadcrumbs
    <<-HTML.strip_heredoc
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb _board-breadcrumb">
        <li class="breadcrumb-item">#{card.name}</li>
        <li class="breadcrumb-item active">Edit</li>
      </ol>
    </nav>
    HTML
  end

  def board_link_opts opts={}
    opts[:"data-slot-selector"] = board_slot_selector
    opts[:"data-slotter-mode"] = :override
    opts[:remote] = true
    add_class opts, "slotter"
    opts.bury :path, :layout, :overlay
    opts.bury :path, :slot, :items, :view, :accordion_bar
    opts[:path][:view] ||= :content
    opts
  end

  def board_slot_selector
    ".board-main > .overlay-container > .card-slot._bottomlay-slot," \
    ".board-main > ._overlay-container-placeholder > .card-slot"
  end

  def default_board_tab
    show_guide_tab? ? :guide_tab : :engage_tab
  end

  def breadcrumb_data title, html_class=nil
    html_class ||= title.underscore
    { "data-breadcrumb": title, "data-breadcrumb-class": html_class }
  end

  def board_menu
    wrap_with_modal_menu do
      [
        render_close_modal_link,
        switch_to_edit_link
      ]
    end
  end

  def switch_to_edit_link
    edit_link_opts = {
      "data-slotter-mode": "modal-replace",
      "data-modal-class": "modal-lg"
    }
    confirm_edit_loss(edit_link_opts)
    link_to_view(:edit, menu_icon, edit_link_opts)
  end
end
