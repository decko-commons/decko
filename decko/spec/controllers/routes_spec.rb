# -*- encoding : utf-8 -*-
require "decko/rest_spec_helper"

Decko::RestSpecHelper.describe_api do
  describe "route handling" do
    def route_to_card opts={}
      route_to opts.merge(controller: "card")
    end

    it "routes index to #read" do
      expect(get: "/").to route_to_card(action: "read")
    end

    it "recognizes file urls without size" do
      expect(get:"/files/~1234/5678.pdf")
        .to route_to_card(action: "read", explicit_file: true,
                          mark: "~1234", rev_id: "5678", format: "pdf")
    end

    it "recognizes file urls with size" do
      expect(get:"/files/~1234/5678-medium.png")
        .to route_to_card(action: "read", explicit_file: true, size: "medium",
                          mark: "~1234", rev_id: "5678", format: "png")
    end

    it "captures additoinal params" do
      expect(get:"/namey?paramy=valuey")
        .to route_to_card(action: "read", mark: "namey", paramy: "valuey")
    end

    it "recognizes format" do
      expect(get: "/:recent.rss")
        .to route_to_card(action: "read", mark: ":recent", format: "rss")
    end

    it "routes http PUT to update action without mark" do
      expect(put: "/").to route_to_card(action: "update")
    end

    it "routes http PUT to update action with mark" do
      expect(put: "/mycard").to route_to_card(action: "update", mark: "mycard")
    end

    it "routes http POST to create action without mark" do
      expect(post: "/").to route_to_card(action: "create")
    end

    it "routes http POST to create action with mark" do
      expect(post: "/chicken").to route_to_card(action: "create", mark: "chicken")
    end

    it "routes http PATCH to update action without mark" do
      expect(patch: "/").to route_to_card(action: "update")
    end

    it "routes http PATCH to update action with mark" do
      expect(patch: "/nibble").to route_to_card(action: "update", mark: "nibble")
    end

    it "routes http DELETE to delete action with mark" do
      expect(delete: "/").to route_to_card(action: "delete")
    end

    it "routes http DELETE to delete action with mark" do
      expect(delete: "/~1234").to route_to_card(action: "delete", mark: "~1234")
    end

    it "handles deprecated asset requests" do
      expect(get: "/asset/application.js")
        .to route_to_card(action: "asset", mark: "application", format: "js")
    end

    it "handles deprecated asset requests" do
      expect(get: "/javascripts/application.js")
        .to route_to_card(action: "asset", mark: "application", format: "js")
    end

    it "recognizes special new/{type} requests" do
      expect(get: "/new/Phrase")
        .to route_to_card(action: "read", type: "Phrase", view: "new")
    end

    it "recognizes special {mark}/view/{view} requests" do
      expect(get: "/cookie/view/eaten")
        .to route_to_card(action: "read", mark: "cookie", view: "eaten")
    end

    it "handles GET alternative for create action" do
      expect(get: "card/create").to route_to_card(action: "create")
    end

    it "handles GET alternative for update action" do
      expect(get: "update/calendar").to route_to_card(action: "update", mark: "calendar")
    end

    it "handles GET alternative for delete action" do
      expect(get: "card/delete/monster")
        .to route_to_card(action: "delete", mark: "monster")
    end

    ["/decko", ""].each do |prefix|
      describe "routes prefixed with '#{prefix}'" do
        it "works without format" do
          expect(get: "#{prefix}/random")
            .to route_to_card(action: "read", mark: "random")
        end

        it "recognizes format" do
          expect(get: "#{prefix}/*recent.xml")
            .to route_to_card(action: "read", mark: "*recent", format: "xml")
        end
      end
    end
  end
end
