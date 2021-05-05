# -*- encoding : utf-8 -*-

require "decko/rest_spec_helper"

Decko::RestSpecHelper.describe_api do
  let(:alias_name) { "My Alias" }
  let(:target_name) { "T" }

  before do
    Card.create! name: alias_name, type_code: :alias, content: target_name
  end

  describe "#read" do
    context "when simple alias" do
      it "redirects to target when no view param" do
        get :read, params: { mark: alias_name }
        expect(response).to redirect_to("/#{target_name}")
      end

      it "does not redirect when view param is present" do
        get :read, params: { mark: alias_name, view: :bar }
        expect(response).to have_http_status(:ok)
      end
    end
  end

  context "when compound alias (compound card in which one part is an alias)" do

  end
end
