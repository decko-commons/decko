RSpec.describe ActiveJob::Arguments do
  describe "#serialize_patch" do
    it "handles symbols" do
      ser = described_class.serialize([:sym])
      deser = described_class.deserialize(ser)
      expect(deser).to eq [:sym]
    end
  end
end
