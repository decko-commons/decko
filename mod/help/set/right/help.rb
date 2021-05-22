include_set Abstract::TemplatedNests

format :html do
  view :popover do
    popover_link _render_core
  end

  def quick_editor
    # TODO: refactor when voo.input_type is ready.  (and use class_up)
    formgroup "Content", input: :content, help: false do
      text_field :content, value: card.content,
                           class: "d0-card-content _submit-after-typing"
    end
  end
end
