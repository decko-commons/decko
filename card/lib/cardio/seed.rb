module Cardio
  # methods in support of seeding
  module Seed
    TABLES = %w[cards card_actions card_acts card_changes card_references
                schema_migrations schema_migrations_core_cards
                schema_migrations_deck schema_migrations_deck_cards].freeze

    class << self
      attr_accessor :path, :test_path

      def db_path *args
        parts = [Cardio.gem_root, "db"] + args
        File.join(*parts)
      end
    end

    self.path = db_path "seed", "new"
    self.test_path = db_path "seed", "test", "fixtures"
  end
end
