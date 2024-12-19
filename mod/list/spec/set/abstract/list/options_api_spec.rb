RSpec.describe Card::Set::Abstract::List::OptionsApi do
  def define_options_rule type_id, content
    Card.create! name: %i[pointer type content_options],
                 type_id: type_id, content: content
  end

  let :sample_pointer do
    Card.new type_id: Card::PointerID
  end

  describe "#options_hash", :as_bot do
    let(:options_hash) do
      sample_pointer.options_hash
    end

    context "when options card is a pointer" do
      before do
        define_options_rule Card::PointerID, %w[A B]
      end

      it "takes name and value from cardname" do
        expect(options_hash).to eq("A" => "A", "B" => "B")
      end
    end

    context "when options card is a JSON" do
      before do
        define_options_rule Card::JsonID, '{"A": "C", "B": "D"}'
      end

      it "takes key/value pairs from JSON hash" do
        expect(options_hash).to eq("A" => "C", "B" => "D")
      end
    end
  end
end
