format :html do
  include AddHelp::HtmlFormat

  view :popover do
    popover_link _render_core
  end

  def quick_editor
    formgroup "content", editor: :content, help: false do
      text_field :content, value: card.content,
                 class: "d0-card-content _submit-after-typing"
    end
  end
end
