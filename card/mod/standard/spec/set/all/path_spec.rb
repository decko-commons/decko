describe Card::Set::All::Path do
  def path *args
    format.path(*args)
  end

  context "when in base format" do
    let :format do
      Card["A"].format(:base)
    end

    it "defaults to format card" do
      expect(path).to eq "/A"
    end
  end
end
