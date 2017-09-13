RSpec.describe Card::Set::All::I18n do
  it "can access scope" do

    expect(Card["A"].format.t(:key))
      .to eq "translation missing: en.mod.spec.set.all.i18n_spec.key"
  end
end
