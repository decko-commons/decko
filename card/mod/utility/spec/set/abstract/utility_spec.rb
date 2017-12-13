describe Card::Set::Abstract::Utility do
  describe "#params_to_i" do
    subject do
      Card["A"].with_set(described_class).param_to_i "offset", 0
    end

    it "returns value from params" do
      Card::Env.params["offset"] = "5"
      is_expected.to eq(5)
    end

    it "returns default" do
      is_expected.to eq(0)
    end
  end
end
