# -*- encoding : utf-8 -*-

RSpec.describe Card::Virtual do
  let(:virtual_content) { "vc" }

  let :card do
    instance_double "virtual card",
                    name: "virtual card".to_name,
                    left_id: 1,
                    right_id: 5,
                    compound?: true,
                    key: "vc_key",
                    virtual_content: virtual_content
  end

  let(:create_virtual) { described_class.save(card) }

  specify ".create" do
    expect(create_virtual.content).to eq virtual_content
  end

  specify ".fetch" do
    create_virtual
    expect(described_class.fetch(card)&.content).to eq virtual_content
  end
end
