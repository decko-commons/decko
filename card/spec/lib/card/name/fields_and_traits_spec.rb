# -*- encoding : utf-8 -*-

describe Card::Name do
  describe "field_of?" do
    it "should identify fields" do
      expect("A+B"  .to_name.field_of? "A"  ).to be_truthy
      expect("A+B"  .to_name.field_of? "B"  ).to be_falsey
      expect("A+B"  .to_name.field_of? "A+B").to be_falsey
      expect("A+B"  .to_name.field_of? "A+C").to be_falsey
      expect("A+B+C".to_name.field_of? "A+B").to be_truthy
      expect("+B"   .to_name.field_of? "A"  ).to be_truthy
      expect("+B"   .to_name.field_of? "A+B").to be_truthy
      expect("+B"   .to_name.field_of? ""   ).to be_truthy
      expect("+B"   .to_name.field_of? nil  ).to be_truthy

    end
  end
end