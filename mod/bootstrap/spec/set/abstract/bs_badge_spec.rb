RSpec.describe Card::Set::Abstract::BsBadge do
  specify "#labeled_badge" do
    expect(format_subject.labeled_badge(5, "Cats"))
      .to have_tag "span.labeled-badge" do
      with_tag("label") { "Cats" }
      with_tag("span.badge") { "5" }
    end
  end
end
