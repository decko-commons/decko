# -*- encoding : utf-8 -*-

RSpec.describe Card::Virtual do
  let(:virtual_content) { "vc" }

  let :card do
    instance_double "virtual card", name: "virtual card".to_name,
                                    left_id: 1,
                                    right_id: 5,
                                    compound?: true,
                                    generate_virtual_content: virtual_content
  end

  let(:create_virtual) { described_class.create(card) }

  specify ".create" do
    expect(create_virtual.content).to eq virtual_content
  end

  specify ".fetch_content" do
    create_virtual
    expect(described_class.fetch_content(card)).to eq virtual_content
  end

  specify ".refresh" do
    expect(described_class.fetch_content(card)).to eq virtual_content
    allow(card).to receive(:generate_virtual_content).and_return "changed"
    described_class.refresh card
    expect(described_class.fetch_content(card)).to eq "changed"
  end
end
