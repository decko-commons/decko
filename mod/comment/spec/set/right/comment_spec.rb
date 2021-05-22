# -*- encoding : utf-8 -*-

describe Card::Set::Right::Comment do
  context "comment addition" do
    it "combines content after save" do
      Card::Auth.as_bot do
        Card["basicname"].update! comment: " and more\n  \nsome lines\n\n"
      end
      expect(Card["basicname"].content).to match(%r{<p>some lines</p>})
    end
  end
end
