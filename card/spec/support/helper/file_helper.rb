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

    def bucket_credentials key
      @buckets ||= bucket_credentials_from_yml_file || {}
      @buckets[key]
    end

    def bucket_credentials_from_yml_file
      file_path = File.expand_path("../../bucket_credentials.yml", __FILE__)
      yml_file = ENV["BUCKET_CREDENTIALS_PATH"] || file_path
      need_bucket_credentials! file_path unless File.exist? yml_file

      YAML.load_file(yml_file).deep_symbolize_keys
    end

    def need_bucket_credentials! file_path
      raise Card::Error,
            "Bucket Credentials required. " \
            "Specify yml file with environmental variable (BUCKET_CREDENTIALS_PATH) " \
            "or add credentials to #{file_path}."
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
