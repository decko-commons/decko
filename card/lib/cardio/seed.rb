module Cardio
  # methods in support of seeding
  module Seed
    TABLES = %w[cards card_actions card_acts card_changes card_references
                schema_migrations schema_migrations_core_cards
                schema_migrations_deck schema_migrations_deck_cards].freeze

    class << self
      attr_accessor :path, :test_path

      def default_path
        env = Rails.env.test? ? "test" : "production"
        db_path env, -1
      end

      def path
        if ENV["UPDATE_SEED"]
          args = Rails.env.test? ? ["production", -1] : ["production", -2]
          db_path *args
        else
          default_path
        end
      end

      private

      def db_path env, index
        paths = Cardio.config.paths["seed_fixtures"]
        File.join paths.existent[index], env
      end
    end

    # self.path = db_path "seed", "minimal"
    # self.path = db_path "seed", "new"
    # self.test_path = db_path "seed", "test", "fixtures"
  end
end
