describe "#bucket config" do
  subject do
    Card.new(name: "test", type_id: Card::FileID,
             empty_ok: true, storage_type: :cloud,
             bucket: :test_bucket).bucket_config
  end

  let(:bucket_config) do
    {
      test_bucket: {
        provider: "fog/aws",
        credentials: {
          provider: "credential_provider",
          region: "region",
          host: "host",
          endpoint: "endpoint",
          aws_access_key_id: "aws_access_key_id",
          aws_secret_access_key: "aws_secret_access_key"
        },
        subdirectory: "files",
        directory: "directory",
        public: true,
        attributes: { "Cache-Control" => "max-age=#{365.day.to_i}" },
        authenticated_url_expiration: 180,
        use_ssl_for_aws: true
      }
    }
  end

  before do
    @old_bucket_config = Cardio.config.file_buckets
    Cardio.config.file_buckets = bucket_config
  end

  after do
    Cardio.config.file_buckets = @old_bucket_config
    %w[PROVIDER CREDENTIALS_PROVIDER TEST_BUCKET_PROVIDER
       TEST_BUCKET_CREDENTIALS_PROVIDER].each do |key|
      ENV.delete key
    end
  end

  it "takes config from Cardio.config" do
    expect(subject).to eq bucket_config[:test_bucket]
  end

  it "raises error if no bucket config given" do
    Cardio.config.file_buckets = {}
    expect { subject }.to raise_error(Card::Error)
  end

  it "takes config from env variables" do
    Cardio.config.file_buckets = {}
    ENV["PROVIDER"] = "env provider"
    ENV["CREDENTIALS_PROVIDER"] = "env cred provider"
    expect(subject).to eq provider: "env provider",
                          credentials: { provider:  "env cred provider" }
  end

  it "overrides Cardio.config with env variables" do
    ENV["PROVIDER"] = "env provider"
    ENV["CREDENTIALS_PROVIDER"] = "env cred provider"
    changed_config = bucket_config[:test_bucket]
    changed_config[:provider] =  "env provider"
    changed_config[:credentials][:provider] = "env cred provider"
    expect(subject).to eq changed_config
  end

  it "prefers bucket specific env variables" do
    ENV["PROVIDER"] = "ignore"
    ENV["CREDENTIALS_PROVIDER"] = "ignore"
    ENV["TEST_BUCKET_PROVIDER"] = "bucket provider"
    ENV["TEST_BUCKET_CREDENTIALS_PROVIDER"] = "bucket cred provider"
    changed_config = bucket_config[:test_bucket]
    changed_config[:provider] =  "bucket provider"
    changed_config[:credentials][:provider] = "bucket cred provider"
    expect(subject).to eq changed_config
  end

  it "finds any credential env variable" do
    ENV["CREDENTIALS_MY_OWN_CLOUD_BUCKET"] = "my provider"
    ENV["CREDENTIALS_MY_OWN_CLOUD"] = "ignore me"
    ENV["TEST_BUCKET_CREDENTIALS_MY_OWN_CLOUD"] = "find me"
    changed_config = bucket_config[:test_bucket]
    changed_config[:credentials][:my_own_cloud_bucket] =  "my provider"
    changed_config[:credentials][:my_own_cloud] = "find me"
    expect(subject).to eq changed_config
  end
end
