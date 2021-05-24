def context_card
  @context_card || self
end

def with_context context_card
  old_context = @context_card
  @context_card = context_card if context_card
  yield
ensure
  @context_card = old_context
end

format do
  delegate :context_card, :with_context, to: :card

  def contextual_content context_card, options={}
    view = options.delete(:view) || :core
    with_context(context_card) { render! view, options }
  end
end
