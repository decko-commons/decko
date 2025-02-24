format :html do
  view :core, cache: :never do
    contextualizing { super() }
  end

  private

  def contextualizing &block
    if @context_card.present? || voo.hide?(:test_context)
      yield
    else
      card.with_context test_context_card, &block
    end
  end

  def test_context_card
    card.left.fetch(:test_context)&.first_card
  end
end

format :email_html do
  view :core do
    process_content render_raw
  end
end

# format :email_text do
#   view :core do
#     process_content render_raw
#   end
# end
