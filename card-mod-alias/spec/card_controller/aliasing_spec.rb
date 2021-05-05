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

  context "when simple alias" do
    describe "#read" do
      it "redirects to target when no view param" do
        get :read, params: { mark: alias_name, format: :json, tab: "soda" }
        expect(response).to redirect_to("/#{target_name}.json?tab=soda")
      end

      it "does not redirect when view param is present" do
        get :read, params: { mark: alias_name, view: :bar }
        expect(response).to have_http_status(:ok)
      end
    end

    specify "#update" do
      login_as "Joe User"
      post :update, params: { mark: alias_name, card: { content: :"Z" } }
      expect(assigns(:card).name).to eq(alias_name)
      expect(response).to redirect_to("/#{alias_name.url_key}")
    end
  end

  context "when compound alias (compound card in which one part is an alias)" do
    specify "#read" do
      get :read, params: { mark: compound_alias }
      expect(response).to redirect_to("/#{compound_target}")
    end

    specify "#update" do
      login_as "Joe User"
      post :update, params: { mark: compound_alias, card: { content: :"Z" } }
      expect(assigns(:card).name).to eq(compound_target)
      expect(response).to redirect_to("/#{compound_target.url_key}")
    end
  end
end
