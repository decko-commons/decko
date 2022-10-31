# -*- encoding : utf-8 -*-

RSpec.describe Card::Env::Success do
  let(:context) { Card["A"].name }
  let(:previous) { "/B" }
  let(:home)     { Card["Home"] }
  let(:success_params) { nil }

  let :success_object do
    Card::Env.save_location Card["B"]
    described_class.new context, success_params
  end

  describe "#target" do
    subject { success_object.target }

    context "when initialized with nil" do
      it { is_expected.to eq Card["A"] }
    end

    context "when initialized with hash" do
      let(:success_params) { { id: home.id, view: "closed" } }

      it { is_expected.to eq home }
    end

    context "when initialized with card object" do
      let(:success_params) { home }

      it { is_expected.to eq home }
    end

    context "when initialized with url" do
      let(:success_params) { "https://decko.org" }

      it { is_expected.to eq "https://decko.org" }
    end
  end

  describe "#to_url" do
    subject { success_object.to_url }

    context "with params" do
      context "when using initialization" do
        let(:success_params) { { id: home.id, view: "closed", layout: "my_layout" } }

        it { is_expected.to eq "/Home?layout=my_layout&view=closed" }
      end

      context "when using array assignment" do
        before { success_object[:view] = "closed" }
        it { is_expected.to eq "/A?view=closed" }
      end

      context "when using assignment" do
        before { success_object.view = "closed" }
        it { is_expected.to eq "/A?view=closed" }
      end

      context "when using <<" do
        before { success_object << { card: home, view: "closed" } }
        it { is_expected.to eq "/Home?view=closed" }
      end
    end

    context "with redirect string" do
      let(:success_params) { { mark: "*previous" } }

      it { is_expected.to eq previous }
    end
  end

  describe "#redirect" do
    subject { success_object.redirect }

    context "when redirect parameter is 'soft'" do
      let(:success_params) { { redirect: "soft" } }

      it { is_expected.to eq "soft" }
    end

    context "when redirect parameter is blank" do
      let(:success_params) { { redirect: "" } }

      it { is_expected.to be_falsey }
    end
  end

  describe "#mark=" do
    subject { success_object.target }

    before { success_object.mark = success_mark }

    context "with id" do
      let(:success_mark) { home.id }

      it { is_expected.to eq home }
    end

    context "with name" do
      let(:success_mark) { home.name }

      it { is_expected.to eq home }
    end

    context "with card" do
      let(:success_mark) { home }

      it { is_expected.to eq home }
    end
  end

  describe "params" do
    let :success_params do
      {
        id: 5,
        name: "Home",
        card: home,
        mark: "Home",
        target: "Home",
        redirect: false,
        view: "View"
      }
    end

    it 'ignores "id", "name", "mark", "card"", target", and "redirect"' do
      expect(success_object.params.keys).to eq [:view]
    end

    it "returns params hash" do
      success_object.layout = "Layout"
      success_object << { structure: "Structure", script: "Script" }
      expect(success_object.params.keys.sort).to eq %i[layout script structure view]
    end
  end
end
