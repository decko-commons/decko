class Card
  module FileHelper
    def test_file no=1
      File.new(File.join(CARD_TEST_SEED_PATH, "file#{no}.txt"))
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
      DIRECTORY = "deckodev-test".freeze

      def with_test_bucket
        return unless (credentials = test_bucket_credentials)
        ensure_test_bucket credentials
        let(:cloud_url) { "http://#{DIRECTORY}.s3.amazonaws.com/files/#{file_path}" }
        yield
      end

      def test_bucket_credentials
        file_path = test_bucket_file_path
        yml_file = ENV["BUCKET_CREDENTIALS_PATH"] || file_path
        if File.exist? yml_file
          YAML.load_file(yml_file).deep_symbolize_keys[:aws]
        else
          need_bucket_credentials! file_path
          nil
        end
      end

      def test_bucket_file_path
        File.expand_path "../../bucket_credentials.yml", __FILE__
      end

      def need_bucket_credentials! file_path
        puts %[
~~~Skipping cloud specs~~~
Cannot run without bucket credentials
  Specify yml file with environmental variable (BUCKET_CREDENTIALS_PATH)
  or add credentials to #{file_path}.
      ]
      end

      def ensure_test_bucket credentials
        Decko.config.file_buckets = {
          test_bucket: {
            provider: "fog/aws",
            credentials: credentials,
            subdirectory: "files",
            directory: DIRECTORY,
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
