class Card
  module FileHelper
    def test_file no=1
      File.new CarrierWave::TestFile.path("file#{no}.txt")
    end

    def create_file_card storage_type, file=test_file, opts={}
      Card::Auth.as_bot do
        Card.create! opts.reverse_merge(name: "file card",
                                        type_id: Card::FileID,
                                        file: file,
                                        storage_type: storage_type,
                                        codename: "file_card_codename")
      end
    end

    def with_storage_config type
      Cardio.config.file_storage = type
      yield.tap do
        Cardio.config.file_storage = :local
      end
    end

    module BucketHelper
      BUCKET = "deckodev-test".freeze

      def with_test_bucket
        return unless (credentials = test_bucket_credentials)

        ensure_test_bucket credentials
        let(:cloud_url) { "http://#{BUCKET}.s3.amazonaws.com/files/#{file_path}" }
        yield
      end

      def test_bucket_credentials
        bucket_from_config || bucket_from_file || need_bucket_credentials!
      end

      def bucket_from_config
        bucket = Cardio.config.file_buckets&.dig :test_bucket
        bucket if bucket&.dig :aws_access_key_id
      end

      def bucket_from_file
        yml_file = File.expand_path test_bucket_file_path
        return unless File.exist? yml_file

        YAML.load_file(yml_file).deep_symbolize_keys[:aws]
      end

      def test_bucket_file_path
        ENV["BUCKET_CREDENTIALS_PATH"] || "#{Cardio.root}/config/test_bucket.yml"
      end

      def need_bucket_credentials!
        puts %(
~~~Skipping cloud specs~~~
Cannot run without bucket credentials. Options:
  1. Specify yml file with environmental variables:
    TEST_BUCKET_AWS_ACCESS_KEY_ID and
    TEST_BUCKET_AWS_SECRET_ACCESS_KEY
  2. or add credentials to #{test_bucket_file_path}
  3. Specify credentials path with BUCKET_CREDENTIALS_PATH
        )
        nil
      end

      def ensure_test_bucket credentials
        Decko.config.file_buckets = {
          test_bucket: {
            provider: "fog/aws",
            credentials: credentials,
            subdirectory: "files",
            directory: BUCKET,
            public: true,
            attributes: { "Cache-Control" => "max-age=#{365.day.to_i}" },
            authenticated_url_expiration: 180
          }
        }
      end
    end

    # expects access keys in card/spec/support/bucket_credentials.yml for the
    # bucket defined in `directory` in the following format:
    # aws:
    #   provider: AWS
    #   aws_access_key_id: ...
    #   aws_secret_access_key: ...
    #   region: eu-central-1
  end
end
