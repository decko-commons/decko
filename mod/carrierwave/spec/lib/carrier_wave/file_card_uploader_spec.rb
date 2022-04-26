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
          .to eq ":logo/carrierwave.svg"
      end
    end

    context "local file" do
      subject { local_file }

      it "returns correct identifier" do
        expect(subject.attachment.db_content)
          .to eq "~#{subject.id}/#{subject.last_action_id}.txt"
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
