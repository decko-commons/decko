# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Abstract::Attachment::Cloud do
  DIRECTORY = "deckodev-test"

  subject do
    with_storage_config :cloud do
      ensure_test_bucket
      create_file_card :cloud, test_file, bucket: :test_bucket
    end
  end

  def ensure_test_bucket
    Decko.config.file_buckets = {
      test_bucket: {
        provider: "fog/aws",
        credentials: bucket_credentials(:aws),
        subdirectory: "files",
        directory: DIRECTORY,
        public: true,
        attributes: { "Cache-Control" => "max-age=#{365.day.to_i}" },
        authenticated_url_expiration: 180
      }
    }
  end

  let(:cloud_url) { "http://#{DIRECTORY}.s3.amazonaws.com/files/#{file_path}" }

  def file_path
    "#{subject.id}/#{subject.last_action_id}.txt"
  end

  describe "db_content" do
    it "stores correct identifier ((<bucket>)/<card id>/<action id>.<ext>)" do
      expect(subject.db_content).to eq("(test_bucket)/#{file_path}")
    end
  end

  describe "file object" do
    it "stores file" do
      expect(subject.file.read.strip).to eq "file1"
    end

    it "generates correct absolute url" do
      expect(subject.file.url).to eq(cloud_url)
    end
  end

  describe "view: source" do
    it "renders absolute url to cloud" do
      expect(subject.format.render_source).to eq(cloud_url)
    end
  end

  context "when changing storage type to cloud" do
    subject { create_file_card :local }

    it "works" do
      # local
      expect(subject.db_content).to eq "~#{file_path}"

      # cloud
      ensure_test_bucket
      subject.update! storage_type: :cloud
      expect(subject.db_content).to eq("(test_bucket)/#{file_path}")
      url = subject.file.url
      expect(url).to eq(cloud_url)
      expect(open(url).read.strip).to eq "file1"
    end
  end

  it "copies file to local file system" do
    # not yet supported
    expect { Card[subject.name].update!(storage_type: :local) }
      .to raise_error(ActiveRecord::RecordInvalid)
  end

  #   describe "cloud" do
  #     before(:context) do
  #       storage_config :cloud
  #       @cloud_card = create_file_card :cloud, test_file, bucket: :test_bucket
  #       storage_config :local
  #     end
  #     after(:context) do
  #       Card::Auth.as_bot do
  #         update "file card", codename: nil
  #         Card["file card"].delete!
  #       end
  #     end
  #     #subject { cloud_file }
  #
  #     it "stores correct identifier "\
  #        "((<bucket>)/<card id>/<action id>.<ext>)" do
  #       expect(@cloud_card.content)
  #         .to eq "(test_bucket)/#{@cloud_card.id}/#{@cloud_card.last_action_id}.txt"
  #     end
  #
  #     it "stores file" do
  #       expect(@cloud_card.file.read.strip).to eq "file1"
  #     end
  #
  #     it "generates correct absolute url" do
  #       expect(@cloud_card.file.url)
  #         .to eq "http://#{DIRECTORY}.s3.amazonaws.com/"\
  #            "files/#{@cloud_card.id}/#{@cloud_card.last_action_id}.txt"
  #     end
  #   end
  # end
end
