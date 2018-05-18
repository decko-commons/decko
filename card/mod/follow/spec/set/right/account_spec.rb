
describe "#send_change_notice" do
  subject(:mail) do
    follower = Card["Joe User"]
    Card[:follower_notification_email].format.mail(
        Card.fetch("A", look_in_trash: true),
        { to: "joe@user.com" },
        auth: follower,
        active_notice: {
            follower:      follower,
            followed_set:  Card[:all],
            follow_option: Card[:always]
        }
    )
  end

  it "works for deleted card" do
    delete "A"
    expect(mail.subject).to eq 'Joe User deleted "A"'
  end

  it "sends multipart email" do
    expect(mail.content_type).to include("multipart/alternative")
  end

  context "denied access" do
    it "excludes protected subcards" do
      skip
      Card.create(name: "A+B+*self+*read", type: "Pointer", content: "[[u1]]")

      u2 = Card.fetch "u2+*following", new: { type: "Pointer" }
      u2.add_item "A"

      a = Card.fetch "A"
      a.update_attributes(content: "new content",
                          subcards: { "+B" => { content: "hidden content" } })
    end

    it "sends no email if changes not visible" do
      skip
    end
  end
end
