describe Card::Set::All::NameValidations, "validate name" do
  it "does not allow empty name" do
    expect { create "" }
      .to raise_error /Name can't be blank/
  end

  it "does not allow mismatched name and key" do
    expect { create "Test", key: "foo" }
      .to raise_error /wrong key/
  end
end
