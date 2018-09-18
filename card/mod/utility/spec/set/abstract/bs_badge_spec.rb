RSpec.describe Card::Set::Abstract::BsBadge do
  specify "#labeled badge" do
    expect(format_subject.labeled_badge(5, "Cats"))
      .to have_tag "span.labeled-badge" do
        with_tag("span.badge") { "5" }
        with_tag("label.mr-2") { "Cats" }
    end
  end
end
