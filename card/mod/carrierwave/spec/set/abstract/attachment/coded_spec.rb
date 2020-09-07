RSpec.describe Card::Set::Abstract::Attachment::Coded do
  ENV["STORE_CODED_FILES"] = "true"

  let :mod_path do
    deck_mod_path = Cardio.paths["mod"].existent.last
    File.join deck_mod_path, "test_mod"
  end

  let(:codename) { :yeti_skin_image }

  subject { Card[codename] }

  specify "view: source" do
    expect(subject.format.render_source)
      .to eq("/files/:#{codename}/bootstrap-medium.png")
  end

  describe "creating" do
    before do
      FileUtils.mkdir_p mod_path
      # file_dir = File.join(mod_path,  "file", "mod_file")
      # FileUtils.mkdir_p file_dir
      # File.open(File.join(file_dir, "test_mod.txt"),"w") do |f|
      #   f.puts "test"
      # end
      Card::Mod.dirs.mod "test_mod"
    end
    after do
      FileUtils.rm_rf mod_path
      Card::Mod.dirs.mods.delete "test_mod"
    end

    subject do
      create_file_card :coded, test_file, codename: "mod_file", mod: "test_mod"
    end

    let(:file_path) { File.join mod_path, "file", "mod_file", "file.txt" }

    it "stores correct identifier (:<codename>/<mod_name>.<ext>)" do
      expect(subject.db_content)
        .to eq ":#{subject.codename}/test_mod.txt"
    end

    it "has correct store path" do
      expect(subject.file.path).to eq file_path
    end

    it "has correct original filename" do
      expect(subject.original_filename).to eq "file1.txt"
    end

    it "stores file in mod directory" do
      subject
      expect(File.read(file_path).strip).to eq "file1"
    end

    it "has correct url" do
      expect(subject.file.url).to(
        eq "/files/:#{subject.codename}/test_mod.txt"
      )
    end
  end
end
