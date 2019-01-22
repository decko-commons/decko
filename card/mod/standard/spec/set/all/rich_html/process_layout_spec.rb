# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::All::RichHtml::ProcessLayout do
  describe "#explicit_modal_wrapper?" do
    subject(:format) { Card["A"].format }

    example "single wrapper" do
      allow(format).to receive(:view_setting).and_return :modal
      expect(format.explicit_modal_wrapper?(:view)).to be_truthy
    end

    example "array of wrappers" do
      allow(format).to receive(:view_setting).and_return [:other, :modal]
      expect(format.explicit_modal_wrapper?(:view)).to be_truthy
    end

    example "array of wrappers with options" do
      allow(format).to receive(:view_setting)
                         .and_return [:other, [:modal, { opts: :a} ]]
      expect(format.explicit_modal_wrapper?(:view)).to be_truthy
    end

    example "hash of wrappers with options" do
      allow(format).to receive(:view_setting)
                         .and_return other: { opt: :a },  modal: { opts: :a }
      expect(format.explicit_modal_wrapper?(:view)).to be_truthy
    end
  end
end
