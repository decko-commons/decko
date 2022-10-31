RSpec.describe Card::Set::All::Bootstrap::Navbar do
  describe "#navbar" do
    it "has toggler button when responsive" do
      expect(format_subject.navbar("xid") { "content" })
        .to have_tag("button.navbar-toggler")
    end

    it "has fluid class with no_collapse" do
      expect(format_subject.navbar("xid", no_collapse: true) { "content" })
        .to have_tag("div.container-fluid")
    end
  end
end
