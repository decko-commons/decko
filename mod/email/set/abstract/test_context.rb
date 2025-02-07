format :html do
  view :core, cache: :never do
    return super() if voo.hide? :test_context

    card.with_context test_context_card do
      super()
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
#     voo.hide! :test_context
#     super()
#   end
# end
