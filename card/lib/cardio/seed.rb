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

      private

      def db_path env, index
        Mod.fetch(Cardio.config.seed_mods[index]).subpath "data", "fixtures", env
      end
    end
  end
end
