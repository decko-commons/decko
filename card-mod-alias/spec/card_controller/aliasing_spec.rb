# -*- encoding : utf-8 -*-
require "decko/rest_spec_helper"

Decko::RestSpecHelper.describe_api do
  let(:alias_name) { "My Alias" }
  let(:target_name) { "T" }

  before do
    Card.create! name: alias_name, type_code: :alias, content: target_name
  end

  describe "#read" do
    context "simple alias" do
      it "redirects to target" do
        get :read, params: { mark: alias_name }
        expect(response).to redirect_to("/#{target_name}")
      end
    end
  end
end
