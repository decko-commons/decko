# -*- encoding : utf-8 -*-

# FIXME: - this shouldn't really be with the controller specs

RSpec.describe CardController, "location test from old integration" do
  routes { Decko::Engine.routes }

  before do
    login_as "joe_user"
  end

  describe "previous location" do
    it "gets updated after viewing" do
      get :read, params: { mark: "Joe_User" }
      assert_equal "/Joe_User", URI.parse(Card::Env.previous_location).path
    end

    it "doesn't link to nonexistent cards" do
      get :read, params: { mark: "Joe_User" }
      get :read, params: { mark: "Not_Me" }
      get :read, params: { mark: "*previous" }
      assert_redirected_to "/Joe_User"
    end
  end
end
