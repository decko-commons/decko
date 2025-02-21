include_set Abstract::TestContext

assign_type :plain_text

format :html do
  view :core do
    contextualizing do
      card.format(:email_text).render_core
    end
  end
end
