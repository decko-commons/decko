RSpec.describe ActiveJob::Arguments, "serialize patch" do
  it "handles symbols" do
    ser = ActiveJob::Arguments.serialize(:symbol)
    deser = ActiveJob::Arguments.deserialze(ser)
    expect(deser).to eq :symbol
  end
end