RSpec.describe Card::Bootstrap do
  subject { described_class.new(format) }

  let(:format) { Card["A"].format(:html) }

  def render &block
    subject.render(&block)
  end

  it "loads components" do
    is_expected.to respond_to(:form)
    expect(subject.form { nil }).to eq "<form></form>"
  end

  describe "html" do
    it "renders plain text" do
      # expect(render { html "test" }).to eq "test"
    end
  end
end
