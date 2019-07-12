# -*- encoding : utf-8 -*-
require "decko/rest_spec_helper"

Decko::RestSpecHelper.describe_api do
  describe "#create" do
    before { login_as "joe_camel" }

    # FIXME: several of these tests go all the way to DB,
    #  which means they're closer to integration than unit tests.
    #  maybe think about refactoring to use mocks etc. to reduce
    #  test dependencies.

    it "redirects standard card creation" do
      post :create, params: { mark: "NewCardFoo" }
      assert_response 302
    end

    it "doesn't redirect cards created in AJAX" do
      post :create, xhr: true, params: { mark: "NewCardFoo" }
      assert_response 200
    end

    it "handles permission denials" do
      post :create, params: { card: { name: "LackPerms", type: "Html" } }
      assert_response 403
    end

    it "handles cards that are createable but not readable", with_user: Card::AnonymousID do
      # Fruits (from shared_data) are anon creatable but not readable
      # login_as :anonymous
      post :create, params: { card: { type: "Fruit", name: "papayan" } }
      assert_response 302
    end

    it "returns an error response if create fails (because it already exists)" do
      post :create, params: { card: { name: "Joe User" } }
      assert_response 422
    end

    it "retains card errors" do
      post :create, params: { "card" => { "name" => "", "type" => "Fruit" } }
      expect(assigns["card"].errors[:name].first).to eq("can't be blank")
    end

    context "success specified in request" do
      it "redirects to thanks if present" do
        post :create, params: { mark: "Wombly", success: "REDIRECT: /thank_you" }
        assert_redirected_to "/thank_you"
      end

      it "redirects to card if thanks is _self" do
        post :create, params: { mark: "Wombly", success: "REDIRECT: _self" }
        assert_redirected_to "/Wombly"
      end

      it "redirects to previous" do
        post :create, params: { mark: "Wombly", success: "REDIRECT: *previous" },
                      session: { history: ["/blam"] }
        assert_redirected_to "/blam"
      end
    end
  end

  describe "#read" do
    it "works for basic request" do
      get :read, params: { mark: "Sample_RichText" }
      expect(response.body).to match(/\<body[^>]*\>/im)
      # have_selector broke in commit 8d3bf2380eb8197410e962304c5e640fced684b9,
      # presumably because of a gem (like capybara?)
      # response.should have_selector('body')
      assert_response :success
      expect("Sample RichText").to eq(assigns["card"].name)
    end

    it "handles nonexistent card with create permission" do
      login_as "joe_user"
      get :read, params: { mark: "Sample_Fako" }
      assert_response :success
    end

    it "handles nonexistent card without create permissions" do
      get :read, params: { mark: "Sample_Fako" }
      assert_response 404
    end

    it "handles nonexistent card ids" do
      get :read, params: { mark: "~9999999" }
      assert_response 404
    end

    it "returns denial when no read permission" do
      Card::Auth.as_bot do
        Card.create! name: "Strawberry", type: "Fruit" # only admin can read
      end
      get :read, params: { mark: "Strawberry" }
      assert_response 403
      get :read, params: { mark: "Strawberry", format: "txt" }
      assert_response 403
    end

    context "view = new" do
      before do
        login_as "joe_user"
      end

      it "works on index" do
        get :read, params: { view: "new" }
        expect(assigns["card"].name).to eq("")
        assert_response :success, "response should succeed"
        assert_equal Card::BasicID, assigns["card"].type_id,
                     "@card type should == Basic"
      end

      it "new with name" do
        get :read, params: { card: { name: "BananaBread" }, view: "new" }
        assert_response :success, "response should succeed"
        assert_equal "BananaBread", assigns["card"].name,
                     "@card.name should == BananaBread"
      end

      it "new with existing name" do
        get :read, params: { card: { name: "A" }, view: "new" }
        # really?? how come this is ok?
        assert_response :success, "response should succeed"
      end

      it "new with type" do
        get :read, params: { card: { type: "Date" }, view: "new" }
        assert_response :success, "response should succeed"
        assert_equal Card::DateID, assigns["card"].type_id,
                     "@card type should == Date"
      end

      it "new should work for creatable nonviewable cardtype" do
        login_as :anonymous
        get :read, params: { type: "Fruit", view: "new" }
        assert_response :success
      end

      it "uses card params name over mark in new cards" do
        get :read, params: { mark: "my_life",
                             card: { name: "My LIFE" }, view: "new" }
        expect(assigns["card"].name).to eq("My LIFE")
      end
    end
  end

  describe "#update" do
    before { login_as "joe_user" }

    it "works" do
      patch :update, xhr: true, params: { mark: "Sample RichHtml",
                                          card: { content: "brand new content" } }
      assert_response :success, "edited card"
      assert_equal "brand new content", Card["Sample RichHtml"].content,
                   "content was updated"
    end

    it "rename without update references should work" do
      f = Card.create! type: "Cardtype", name: "Apple"
      patch :update, xhr: true, params: { mark: "~#{f.id}",
                                          card: { name: "Newt",
                                                  update_referers: "false" } }
      expect(assigns["card"].errors.empty?).not_to be_nil
      assert_response :success
      expect(Card["Newt"]).not_to be_nil
    end

    it "update type_code" do
      post :update, xhr: true, params: { mark: "Sample Basic",
                                         card: { type: "Date" } }
      assert_response :success, "changed card type"
      expect(Card["Sample Basic"].type_code).to eq(:date)
    end
  end

  describe "delete" do
    before { login_as "joe_user" }

    it "redirects standard cards deletion" do
      delete :delete, params: { mark: "A" }
      assert_response 302
      expect(Card["A"]).to eq(nil)
      assert_redirected_to "/"
    end

    it "deletes card and renders directly in AJAX" do
      delete :delete, xhr: true, params: { mark: "A" }
      assert_response :success
      expect(Card["A"]).to eq(nil)
    end

    # FIXME: this fails, but it appears to be a testing artifact
    # The session (and thus the history) gets lost in the
    xit "returns to previous undeleted card after deletion" do
      visit "/A"
      visit "/B"
      delete :delete, params: { mark: "B" }
      assert_redirected_to "/A"
    end
  end
end
