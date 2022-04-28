module Cardio
  # methods in support of seeding
  module Seed
    TABLES = %w[cards card_actions card_acts card_changes card_references
                schema_migrations schema_migrations_core_cards
                schema_migrations_deck schema_migrations_deck_cards].freeze

    class << self
      def default_path
        db_path Cardio.config.seed_type, 0
      end

      def path
        if ENV["UPDATE_SEED"]
          db_path :production, (Rails.env.test? ? 0 : 1)
        else
          default_path
        end
      end

      def load
        ActiveRecord::FixtureSet.create_fixtures path, load_tables
      end

      def dump
        dump_tables.each do |table|
          i = "000" # TODO: use card keys instead (this is just a label)
          write_seed_file table do
            yamlize_records table do |record, hash|
              hash["#{table}_#{i.succ!}"] = record
            end
          end
        end
      end

      def clean
        Card::Act.update_all actor_id: author_id
        clean_history
        clean_time_and_user_stamps
      end

      private

      # TODO: make this more robust. only handles simple case of extra seed tables
      def load_tables
        ENV["UPDATE_SEED"] && !Rails.env.test? ? TABLES : dump_tables
      end

      def dump_tables
        TABLES + Cardio.config.extra_seed_tables
      end

      def db_path env, index
        Mod.fetch(Cardio.config.seed_mods[index]).subpath "data", "fixtures", env.to_s
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

      def clean_history
        puts "clean history"
        act = Card::Act.create! actor_id: author_id, card_id: author_id
        Card::Action.make_current_state_the_initial_state act
        Card::Act.where("id <> #{act.id}").delete_all
        ActiveRecord::Base.connection.execute("truncate sessions")
      end

      def clean_time_and_user_stamps
        puts "clean time and user stamps"
        conn = ActiveRecord::Base.connection
        conn.update "UPDATE cards SET creator_id=#{author_id}, updater_id=#{author_id}"
        conn.update "UPDATE card_acts SET actor_id=#{author_id}"
      end

      def author_id
        Card::WagnBotID
      end
    end
  end
end
