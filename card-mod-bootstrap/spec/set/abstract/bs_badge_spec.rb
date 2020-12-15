RSpec.describe Card::Set::Abstract::BsBadge do
  specify "#labeled_badge" do
    expect(format_subject.labeled_badge(5, "Cats"))
      .to have_tag "span.labeled-badge" do
      with_tag("span.badge") { "5" }
      with_tag("label.text-muted") { "Cats" }
    end
  end
end
