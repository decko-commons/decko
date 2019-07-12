RSpec.describe Card::Set::Right::EnabledRoles do
  it "doesn't allow illegal roles", with_user: "Joe User" do
    expect { create_session(["Joe User", :enabled_roles], "[[Administrator]]") }
      .to raise_error(/illegal roles/)
  end

  it "disables roles", with_user: "Joe User" do
    create_session(["Joe User", :enabled_roles], "Shark")
    expect(Card["Joe User"].all_enabled_roles)
      .to contain_exactly Card::SharkID
  end
end
