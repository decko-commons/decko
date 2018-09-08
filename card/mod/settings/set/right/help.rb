format :html do
  include AddHelp::HtmlFormat

  view :popover do
    popover_link _render_core
  end
end
