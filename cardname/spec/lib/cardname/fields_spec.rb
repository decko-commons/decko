# -*- encoding : utf-8 -*-

describe Cardname::Fields do
  describe "field_of?" do
    it "identifies fields" do
      expect("A+B".to_name).to be_field_of("A")
      expect("A+B".to_name).not_to be_field_of("B")
      expect("A+B".to_name).not_to be_field_of("A+B")
      expect("A+B".to_name).not_to be_field_of("A+C")
      expect("A+B+C".to_name).to be_field_of("A+B")
      expect("+B".to_name).to be_field_of("A")
      expect("+B".to_name).to be_field_of("A+B")
      expect("+B".to_name).to be_field_of("")
      expect("+B".to_name).to be_field_of(nil)
    end
  end
end
