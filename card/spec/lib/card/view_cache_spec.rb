# -*- encoding : utf-8 -*-

RSpec.describe Card::View do
  it "cache gets cleared by Card::Cache.reset_all" do
    Card::View.cache.write "testkey", 1
    expect(Card::View.cache.exist? "testkey").to be_truthy
    Card::Cache.reset_all
    expect(Card::View.cache.exist? "testkey").to be_falsey
  end

  def html_message_for user
    Card["follower notification email"].format.mail(
      Card["All Eyes On Me"],
      { to: "#{user}@user.com" },
      auth: user,
      active_notice: {
        follower: user,
        followed_set: "All Eyes On Me+*self",
        follow_option: "*always"
      }
    ).html_part.body.raw_source
  end

  example "email templates" do
    html_message_for "John"
    msg = html_message_for "Sara"
    expect(msg).to include("update/Sara+*follow")
               .and not_include "John"
  end
end
