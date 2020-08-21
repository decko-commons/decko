# -*- encoding : utf-8 -*-

describe Card::Migration::Import do
  let(:path) { Card::Migration.data_path }
  let(:importer) { Card::Migration::Import.new path }

  def card_meta_path
    Card::Migration::Import::ImportData.new(path).instance_variable_get("@path")
  end

  def card_content_dir
    Card::Migration::Import::ImportData.new(path).instance_variable_get("@card_content_dir")
  end

  def meta_data
    YAML.load_file(card_meta_path).deep_symbolize_keys
  end

  def content_path filename
    File.join(card_content_dir, filename)
  end

  def content_data_file filename
    File.read content_path filename
  end

  before(:each) do
    FileUtils.rm card_meta_path if File.exist? card_meta_path
    FileUtils.rm_rf card_content_dir if Dir.exist? card_content_dir
  end

  describe ".add_remote" do
    it "adds remote to yml file" do
      importer.add_remote "test", "url"
      remotes = meta_data[:remotes]
      expect(remotes[:test]).to eq "url"
    end
  end

  describe ".pull" do
    it "saves card attributes" do
      importer.pull "A"
      cards = meta_data[:cards]
      expect(cards).to be_instance_of(Array)
      expect(cards.first[:name]).to eq "A"
      expect(cards.first[:type]).to eq "RichText"
    end

    it "saves card content" do
      importer.pull "A"
      expect(content_data_file("a")).to eq "Alpha [[Z]]"
    end

    context "called with deep: true" do
      it "saves nested card" do
        importer.pull "B", deep: true
        expect(content_data_file("z")).to eq "I'm here to be referenced to"
      end

      it "does not save linked card" do
        importer.pull "A", deep: true
        expect(File.exist?(content_path("z"))).to be_falsey
      end

      it "saves pointer items" do
        importer.pull "Fruit+*type+*create", deep: true
        expect(File.exist?(content_path("anyone"))).to be_truthy
      end
    end
  end

  describe ".merge" do
    it "updates card content" do
      importer.pull "A"
      File.write content_path("a"), "test"
      importer.merge
      expect(Card["A"].content).to eq "test"
    end
  end
end
