describe Card::Set::All::Path do
  def path *args
    format.path(*args)
  end

  def with_complex_env &block
    Cardio.with_config deck_origin: "http://mydomain.com",
                       relative_url_root: "/root",
                       &block
  end

  context "when in base format" do
    let :format do
      Card["A"].format(:base)
    end

    it "defaults to format card" do
      expect(path).to eq "/A"
    end

    it "handles other cards" do
      expect(path(mark: "B")).to eq "/B"
    end

    it "handles codenames" do
      expect(path(mark: :all)).to eq "/*all"
    end

    it "handles ids" do
      expect(path(mark: Card::SetID)).to eq "/Set"
    end

    it "handles unknown ids" do
      expect(path(mark: 999_999)).to eq "/"
    end

    it "handles :no_mark" do
      expect(path(no_mark: true, id: "Donate")).to eq "/?id=Donate"
    end

    it "handles formats" do
      expect(path(format: :csv)).to eq "/A.csv"
    end

    it "handles actions" do
      expect(path(action: :update)).to eq "/update/A"
    end

    it "handles views" do
      expect(path(view: :bar)).to eq "/A/bar"
    end

    it "handles arbitrary query strings" do
      expect(path(preview: :bar)).to eq "/A?preview=bar"
    end

    it "handles special new card of type paths" do
      expect(path(mark: :pointer, action: :new)).to eq("/new/Pointer")
    end

    it "renders as absolute url" do
      with_complex_env do
        expect(path).to eq("http://mydomain.com/root/A")
      end
    end

    it "casts slot[hide] as array" do
      slot_hide = CGI.escape "slot[hide][]"
      expect(path(slot: { hide: "myview" })).to eq("/A?#{slot_hide}=myview")
    end
  end

  context "when in html format" do
    let :format do
      Card["A"].format(:html)
    end

    it "renders as absolute path (not absolute url)" do
      with_complex_env do
        expect(path).to eq("/root/A")
      end
    end
  end
end
