# -*- encoding : utf-8 -*-

RSpec.describe CarrierWave::FileCardUploader do
  let(:local_file) { create_file_card :local }
  let(:coded_file) { Card[:logo] }
  let(:web_file) { create_file_card :web, "http://web.de/test.txt" }

  describe "#db_content" do
    context "coded file" do
      subject { coded_file }

      it "returns correct identifier" do
        expect(subject.attachment.db_content)
          .to eq ":logo/standard.svg"
      end

      it "handles storage options" do
        subject.last_action_id
        expect(subject.attachment.db_content(storage_type: :local))
          .to eq "~#{subject.id}/#{subject.last_action_id}.svg"
      end
    end

    context "local file" do
      subject { local_file }

      it "returns correct identifier" do
        expect(subject.attachment.db_content)
          .to eq "~#{subject.id}/#{subject.last_action_id}.txt"
      end

      it "handles storage options" do
        db_content =
          subject.attachment.db_content(storage_type: :coded, mod: "test_mod")
        expect(db_content).to eq ":file_card_codename/test_mod.txt"
      end

      it "without codename fails for storage option :coded" do
        subject.codename = nil
        expect do
          subject.attachment.db_content(storage_type: :coded, mod: "test_mod")
        end.to raise_error(
          Card::Error, "codename needed for storage type :coded"
        )
      end
    end

    context "web file" do
      subject { web_file }

      it "returns correct identifier" do
        expect(subject.attachment.db_content)
          .to eq "http://web.de/test.txt"
      end
    end
  end
end
