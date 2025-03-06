# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::All::ProcessLayout, "#explicit_modal_wrapper" do
  describe "#explicit_modal_wrapper?" do
    subject(:format) { Card["A"].format }

    example "single wrapper" do
      allow(format).to receive(:view_setting).and_return :modal
      expect(format).to be_explicit_modal_wrapper(:view)
    end

    example "array of wrappers" do
      allow(format).to receive(:view_setting).and_return %i[other modal]
      expect(format).to be_explicit_modal_wrapper(:view)
    end

    example "array of wrappers with options" do
      allow(format).to receive(:view_setting)
        .and_return [:other, [:modal, { opts: :a }]]
      expect(format).to be_explicit_modal_wrapper(:view)
    end

    example "hash of wrappers with options" do
      allow(format).to receive(:view_setting)
        .and_return other: { opt: :a },  modal: { opts: :a }
      expect(format).to be_explicit_modal_wrapper(:view)
    end
  end
end
