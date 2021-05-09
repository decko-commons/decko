# -*- encoding : utf-8 -*-

RSpec.describe Card::Env::Success do
  let(:context) { Card["A"].name }
  let(:previous) { "/B" }
  let(:home)     { Card["Home"] }

  def success_params params
    Card::Env.save_location Card["B"]
    @success = Card::Env::Success.new context, params
  end

  describe "#target" do
    subject { @success.target }

    context "initialized with nil" do
      before do
        success_params nil
      end

      it { is_expected.to eq Card["A"] }
    end

    context "initialized with hash" do
      before do
        success_params id: home.id, view: "closed"
      end

      it { is_expected.to eq home }
    end

    context "initialized with card object" do
      before do
        success_params home
      end

      it { is_expected.to eq home }
    end

    context "initialized with url" do
      before do
        success_params "https://decko.org"
      end

      it  { is_expected.to eq "https://decko.org" }
    end
  end

  describe "#to_url" do
    subject { @success.to_url }

    context "with params" do
      context "using initilization" do
        before do
          success_params id: home.id, view: "closed", layout: "my_layout"
        end

        it { is_expected.to eq "/Home?layout=my_layout&view=closed" }
      end

      context "using array assignment" do
        before do
          success_params nil
          @success[:view] = "closed"
        end

        it { is_expected.to eq "/A?view=closed" }
      end

      context "using assignment" do
        before do
          success_params nil
          @success.view = "closed"
        end

        it { is_expected.to eq "/A?view=closed" }
      end

      context "using <<" do
        before do
          success_params nil
          @success << { card: home, view: "closed" }
        end

        it { is_expected.to eq "/Home?view=closed" }
      end
    end

    context "redirect string" do
      before do
        success_params mark: "*previous"
      end

      it { is_expected.to eq previous }
    end
  end

  describe "#redirect" do
    it "returns soft if redirect parameter is set to soft" do
      success_params redirect: "soft"
      expect(@success.redirect).to eq("soft")
    end

    it "is false for blank redirect parameter" do
      success_params redirect: ""
      expect(@success.redirect).to be false
    end
  end

  describe "#mark=" do
    subject { @success.target }

    before do
      success_params nil
    end

    it "works with id" do
      @success.mark = home.id
      is_expected.to eq home
    end

    it "works with name" do
      @success.mark = home.name
      is_expected.to eq home
    end

    it "works with card object" do
      @success.mark = home
      is_expected.to eq home
    end
  end

  describe "params" do
    it "returns params hash" do
      success_params name: "Home", view: "View"
      @success.layout = "Layout"
      @success << { structure: "Structure", script: "Script" }
      expect(@success.params.keys.sort).to eq %i[layout script structure view]
    end

    it 'ignores "id", "name", "mark", "card"", target", and "redirect"' do
      success_params(id: 5,
                     name: "Home",
                     card: Card["Home"],
                     mark: "Home",
                     target: "Home",
                     redirect: false,
                     view: "View")
      expect(@success.params.keys).to eq [:view]
    end
  end
end
