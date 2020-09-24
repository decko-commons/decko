describe Card::Set::All::Notify::HtmlViews do
  specify "view last_action" do
    expect_view(:last_action).to have_tag("a.known-card") do
      with_tag "span.card-title"
    end
  end
end
