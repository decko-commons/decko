format :html do
  view :flash, cache: :never do
    flash_notice = params[:flash] || Env.success.flash
    return "" unless flash_notice.present? && focal?
    Array(flash_notice).join "\n"
  end

  view :last_action, perms: :none, cache: :never do
    _render_last_action_verb
  end

  def wrap_list list
    "<ul>#{list}</ul>\n"
  end

  def wrap_list_item item
    "<li>#{item}</li>\n"
  end

  def wrap_subedit_item
    "<li>#{yield}</li>\n"
  end
end
