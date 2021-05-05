# -*- encoding : utf-8 -*-

require "decko/rest_spec_helper"

Decko::RestSpecHelper.describe_api do
  let(:alias_name) { "My Alias".to_name }
  let(:target_name) { "T".to_name }
  let(:compound_alias) { Card::Name[alias_name, "randomfieldname"] }
  let(:compound_target) { Card::Name[target_name, "randomfieldname"] }

  before do
    Card.create! name: alias_name, type_code: :alias, content: target_name
  end

  describe "#read" do
    context "when simple alias" do
      it "redirects to target when no view param" do
        get :read, params: { mark: alias_name, format: :json, tab: "soda" }
        expect(response).to redirect_to("/#{target_name}.json?tab=soda")
      end

      it "does not redirect when view param is present" do
        get :read, params: { mark: alias_name, view: :bar }
        expect(response).to have_http_status(:ok)
      end
    end

    it "redirects compound cards" do
      get :read, params: { mark: compound_alias }
      expect(response).to redirect_to("/#{compound_target}")
    end
  end

  describe "#update" do
    def expect_update mark, result
      login_as "Joe User"
      post :update, params: { mark: mark, card: { content: "Z" } }
      expect(assigns(:card).name).to eq(result)
      expect(response).to redirect_to("/#{result.url_key}")
    end

    it "applies to alias card when simple" do
      expect_update alias_name, alias_name
    end

    it "applies to target card when compound" do
      expect_update compound_alias, compound_target
    end
  end
end
