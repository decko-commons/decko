describe Card::Set::All::NameValidations, "validate name" do
  it "errors on name with /" do
    expect { create "testname/" }
      .to raise_error /Name may not contain/
  end

  it "errors on junction name  with /" do
    expect { create "jasmin+ri/ce" }
      .to raise_error /Name may not contain/
  end

  it "does not allow empty name" do
    expect { create "" }
      .to raise_error /Name can't be blank/
  end

  it "does not allow mismatched name and key" do
    expect { create "Test", key: "foo" }
      .to raise_error /wrong key/
  end
end
