module Cardio
  # methods in support of seeding
  module Seed
    TABLES = %w[cards card_actions card_acts card_changes card_references
                schema_migrations schema_migrations_core_cards
                schema_migrations_deck schema_migrations_deck_cards].freeze

    class << self
      def default_path
        env = Rails.env.test? ? "test" : "production"
        db_path env, 0
      end

      def path
        if ENV["UPDATE_SEED"]
          args = Rails.env.test? ? ["production", 0] : ["production", 1]
          db_path(*args)
        else
          default_path
        end
      end

      def dump
        TABLES.each do |table|
          i = "000" # TODO: use card keys instead (this is just a label)
          write_seed_file table do
            yamlize_records table do |record, hash|
              hash["#{table}_#{i.succ!}"] = record
            end
          end
        end
      end

      private

      def db_path env, index
        Mod.fetch(Cardio.config.seed_mods[index]).subpath "data", "fixtures", env
      end

      def write_seed_file table
        filename = File.join default_path, "#{table}.yml"
        File.open(filename, "w") { |file| file.write yield }
      end

      def yamlize_records table
        data = ActiveRecord::Base.connection.select_all "select * from #{table}"
        YAML.dump(
          data.each_with_object({}) do |record, hash|
            try "clean_#{table}_record", record
            yield record, hash
          end
        )
      end

      def clean_card_actions_record record
        record["draft"] = false # needed?
      end

      def clean_card_record record
        record["trash"] = false # needed?
        %w[created_at updated_at current_revision_id references_expired].each do |key|
          record.delete key
        end
      end
    end
  end
end
