# -*- encoding : utf-8 -*-

RSpec.describe Card::Cache do
  let(:cache) { described_class.new prefix: "prefix", store: store }
  let(:store) { nil }

  describe "with nil store" do
    describe "#basic operations" do
      it "works" do
        cache.write("a", "foo")
        expect(cache.read("a")).to eq("foo")
        cache.fetch("b") { "bar" }
        expect(cache.read("b")).to eq("bar")
        cache.reset
      end
    end
  end

  describe "with same cache_id" do
    let(:store) { ActiveSupport::Cache::MemoryStore.new }
    let(:cache) { described_class.new store: store }
    let(:prefix) { cache.hard.prefix }

    it "#read" do
      expect(store).to receive(:read).with("#{prefix}/foo")
      cache.read("foo")
    end

    it "#write" do
      expect(store).to receive(:write).with("#{prefix}/foo", "val")
      cache.write("foo", "val")
      expect(cache.read("foo")).to eq("val")
    end

    it "#fetch" do
      block = proc { "hi" }
      expect(store).to receive(:fetch).with("#{prefix}/foo", &block)
      cache.fetch("foo", &block)
    end

    it "#delete" do
      expect(store).to receive(:delete).with("#{prefix}/foo")
      cache.delete "foo"
    end

    it "#soft.write" do
      cache.soft.write("a", "foo")
      expect(cache.read("a")).to eq("foo")
      expect(store).not_to receive(:write)
      expect(cache.hard.read("a")).to eq(nil)
    end
  end

  it "#reset" do
    store = ActiveSupport::Cache::MemoryStore.new
    cache = described_class.new store: store, database: "mydb"

    expect(cache.hard.prefix).to match(/^mydb-/)
    cache.write("foo", "bar")
    expect(cache.read("foo")).to eq("bar")

    # reset
    cache.reset
    expect(cache.hard.prefix).to match(/^mydb-/)
    expect(cache.read("foo")).to be_nil

    cache2 = described_class.new store: store, database: "mydb"
    expect(cache2.hard.prefix).to match(/^mydb-/)
  end

  describe "with file store" do
    let :cache_path do
      "#{Decko.root}/tmp/cache".tap do |path|
        FileUtils.mkdir_p path unless File.directory? path
      end
    end
    let :store do
      ActiveSupport::Cache::FileStore.new(cache_path).tap &:clear
    end

    describe "#basic operations with special symbols" do
      it "works" do
        cache.write('%\\/*:?"<>|', "foo")
        cache2 = described_class.new store: store, prefix: "prefix"
        expect(cache2.read('%\\/*:?"<>|')).to eq("foo")
        cache.reset
      end
    end

    describe "#basic operations with non-latin symbols" do
      it "works" do
        cache.write("(汉语漢語 Hànyǔ; 华语華語 Huáyǔ; 中文 Zhōngwén", "foo")
        cache.write("русский", "foo")
        cache3 = described_class.new store: store, prefix: "prefix"
        cached = cache3.read "(汉语漢語 Hànyǔ; 华语華語 Huáyǔ; 中文 Zhōngwén"
        expect(cached).to eq("foo")
        expect(cache3.read("русский")).to eq("foo")
        cache.reset
      end
    end

    describe "#tempfile" do
      # TODO
    end
  end
end
