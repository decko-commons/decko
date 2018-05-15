# -*- encoding : utf-8 -*-

RSpec.shared_examples_for "virtual content" do |virtual_content|
  let(:vc) { virtual_content }
  
  it "saves content in virtual table" do
    virtual = Card::Virtual.find_by_content vc
    aggregate_failures do
      expect(virtual.left_id).to eq Card.fetch_id(:all)
      expect(Card.fetch(:all, :machine_cache).content).to eq vc
    end
  end

  it "doesn't save content in cards table" do
    expect(Card.search(content: vc)).to be_empty
  end
end

RSpec.describe Card::Set::Right::MachineCache, as_bot: true do
  VIRTUAL_CONTENT = "be or not to be".freeze

  def create_virtual
    Card.create name: "*all+*machine_cache", content: VIRTUAL_CONTENT
  end

  def update_virtual
    Card.fetch(:all, :machine_cache).update_attributes! content: VIRTUAL_CONTENT
  end

  context "when content is updated" do
    before { update_virtual }
    include_examples "virtual content", VIRTUAL_CONTENT
  end

  context "when card is created" do
    before { create_virtual }
    include_examples "virtual content", VIRTUAL_CONTENT
  end

  context "when trash is set to true" do
    before do
      create_virtual
      card = Card.fetch(:all, :machine_cache)
      card.update_attributes! trash: true
    end

    it "deletes content in virtual table" do
      virtual = Card::Virtual.find_by_content VIRTUAL_CONTENT
      expect(virtual).to be_nil
    end
  end

  context "when deleted" do
    before do
      create_virtual
      Card.fetch(:all, :machine_cache).delete
    end

    it "deletes content in virtual table" do
      virtual = Card::Virtual.find_by_content VIRTUAL_CONTENT
      expect(virtual).to be_nil
    end
  end
end
