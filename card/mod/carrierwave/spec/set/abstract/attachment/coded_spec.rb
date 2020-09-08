RSpec.describe Card::Set::Abstract::Attachment::Coded do
  ENV["STORE_CODED_FILES"] = "true"

  let :mod_path do
    deck_mod_path = Cardio.paths["mod"].existent.last
    File.join deck_mod_path, "test_mod"
  end

  let(:codename) { :yeti_skin_image }

  let(:file_card) { Card[codename] }

  before do
    FileUtils.mkdir_p mod_path
    Card::Mod.dirs.mod "test_mod"
  end

  after do
    FileUtils.rm_rf mod_path
    Card::Mod.dirs.mods.delete "test_mod"
  end

  specify "view: source" do
    expect(file_card.format.render_source)
      .to eq("/files/:#{codename}/bootstrap-medium.png")
  end

  describe "creating" do
    let :file_card do
      create_file_card :coded, test_file, codename: "mod_file", mod: "test_mod"
    end

    let(:file_path) { File.join mod_path, "file", "mod_file", "file.txt" }

    it "stores correct identifier (:<codename>/<mod_name>.<ext>)" do
      expect(file_card.db_content)
        .to eq ":#{file_card.codename}/test_mod.txt"
    end

    it "has correct store path" do
      expect(file_card.file.path).to eq file_path
    end

    it "has correct original filename" do
      expect(file_card.original_filename).to eq "file1.txt"
    end

    it "stores file in mod directory" do
      file_card
      expect(File.read(file_path).strip).to eq "file1"
    end

    it "has correct url" do
      expect(file_card.file.url).to eq("/files/:#{file_card.codename}/test_mod.txt")
    end
  end

  describe "updating" do
    let :file_card do
      create_file_card :coded, test_file, codename: "mod_file", mod: "test_mod"
    end

    let :id_filenames do
      "#{file_card.id}/#{file_card.last_action_id}"
    end

    it "changes storage type to default" do
      with_storage_config :local do
        file_card.update! file: test_file(2)
        expect(file_card.storage_type).to eq :local
        expect(file_card.db_content)
          .to eq("~#{file_card.id}/#{file_card.last_action_id}.txt")
      end
    end

    it "keeps storage type coded if explicitly set" do
      with_storage_config :local do
        file_card.update! file: test_file(2), storage_type: :coded
        expect(file_card.storage_type).to eq(:coded)
        expect(file_card.db_content).to eq(":#{file_card.codename}/test_mod.txt")
        expect(file_card.attachment.path).to match(%r{test_mod/file/mod_file/file.txt$})
        expect(File.read(file_card.attachment.path).strip).to eq "file2"
      end
    end

    context "when changing from local to coded" do
      let(:file_path) { File.join mod_path, "file", "mod_file", "file.txt" }
      let(:file_card) { create_file_card :local }

      it "copies file to mod" do
        expect(file_card.db_content).to eq("~#{id_filenames}.txt")
        Card::Auth.as_bot do
          file_card.update! storage_type: :coded, mod: "test_mod", codename: "mod_file"
        end
        expect(file_card.db_content).to eq(":#{file_card.codename}/test_mod.txt")
        expect(File.exist?(file_path)).to be_truthy
      end
    end

    context "when changing from coded to local" do
      let(:file_card) { Card[:logo] }

      it "copies file to local file" do
        Card::Auth.as_bot do
          file_card.update! storage_type: :local
        end
        expect(file_card.db_content).to eq("~#{id_filenames}.svg")
      end
    end
  end
end
