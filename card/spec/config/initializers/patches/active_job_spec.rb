RSpec.describe ActiveJob::Arguments, "serialize patch" do
  it "handles symbols" do
    ser = ActiveJob::Arguments.serialize([:sym])
    deser = ActiveJob::Arguments.deserialize(ser)
    expect(deser).to eq [:sym]
  end
end