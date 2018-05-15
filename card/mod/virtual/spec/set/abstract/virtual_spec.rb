# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Abstract::Virtual do
  VIRTUAL_CONTENT = "vc".freeze

  let(:card) do
    double("virtual card", junction?: true,
           generate_virtual_content: VIRTUAL_CONTENT,
           left_id: 1, right_id: 5)
  end

  let(:create_virtual) { described_class.create(card) }

  specify ".create" do
    expect(create_virtual.content).to eq "vc"
  end

  specify ".fetch_content" do
    create_virtual
    expect(described_class.fetch_content(card)).to eq VIRTUAL_CONTENT
  end

  specify ".refresh" do
    expect(described_class.fetch_content(card)).to eq VIRTUAL_CONTENT
    allow(card).to receive(:generate_virtual_content).and_return "changed"
    described_class.refresh card
    expect(described_class.fetch_content(card)).to eq "changed"
  end
end
