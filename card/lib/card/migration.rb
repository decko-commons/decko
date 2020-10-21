# -*- encoding : utf-8 -*-

class Card
  class Migration < ActiveRecord::Migration[4.2]
    include Card::Model::SaveHelper
    @type = :deck_cards

    class << self
      # Rake tasks use class methods, migrations use instance methods.
      # To avoid repetition a lot of instance methods here just call class
      # methods.
      # The subclass Card::CoreMigration needs a different @type so we can't use a
      # class variable @@type. It has to be a class instance variable.
      # Migrations are subclasses of Card::Migration or Card::CoreMigration
      # but they don't inherit the @type. The method below solves this problem.
      def type
        @type || (ancestors[1]&.type)
      end

      def find_unused_name base_name
        test_name = base_name
        add = 1
        while Card.exists?(test_name)
          test_name = "#{base_name}#{add}"
          add += 1
        end
        test_name
      end

      def migration_paths mig_type=type
        Card.migration_paths mig_type
      end

      def schema mig_type=type
        Card.schema mig_type
      end

      def schema_suffix mig_type=type
        Card.schema_suffix mig_type
      end

      def schema_mode mig_type=type
        Card.with_suffix mig_type do
          paths = Card.migration_paths(type)
          yield(paths)
        end
      end

      def assume_migrated_upto_version
        schema_mode do
          ActiveRecord::Schema.assume_migrated_upto_version schema,
                                                            migration_paths
        end
      end

      def data_path filename=nil
        path = migration_paths.first
        File.join([path, "data", filename].compact)
      end
    end

    def contentedly
      Card::Cache.reset_all
      Card.schema_mode "" do
        Card::Auth.as_bot do
          yield
        ensure
          ::Card::Cache.reset_all
        end
      end
    end

    # def disable_ddl_transaction #:nodoc:
    #   true
    # end

    def import_json filename, merge_opts={}
      Card::Mailer.perform_deliveries = false
      output_file = File.join data_path, "unmerged_#{filename}"
      merge_opts[:output_file] ||= output_file
      Card.merge_list read_json(filename), merge_opts
    end

    def import_cards filename, merge_opts={}
      Card::Mailer.perform_deliveries = false
      output_file = File.join data_path, "unmerged_#{filename}"
      merge_opts[:output_file] ||= output_file
      meta_data = JSON.parse(File.read(data_path(filename)))
      full_data =
        meta_data.map do |hash|
          hash["content"] =
            File.read data_path(File.join("cards", hash["name"].to_name.key))
          hash
        end
      Card.merge_list full_data, merge_opts
    end

    # uses the data in cards.yml and the card content in db/migrate_cards/data/cards
    # to update or create the cards given by name or key in names_or_keys
    def merge_cards names_or_keys
      names_or_keys = Array(names_or_keys)
      Card::Mailer.perform_deliveries = false

      Card::Migration::Import.new(data_path).merge only: names_or_keys
    end

    def merge_pristine_cards names_or_keys
      names_or_keys = Array(names_or_keys)

      pristine = names_or_keys.select { |n| !Card.exists?(n) || Card.fetch(n)&.pristine? }
      merge_cards pristine
    end

    def read_json filename
      raw_json = File.read data_path(filename)
      json = JSON.parse raw_json
      json.is_a?(Hash) ? json["card"]["value"] : json
    end

    def data_path filename=nil
      self.class.data_path filename
    end

    def schema_mode
      Card.schema_mode self.class.type
    end

    def migration_paths
      Card.paths self.class.type
    end

    # Execute this migration in the named direction
    # copied from ActiveRecord to wrap 'up' in 'contentendly'
    def exec_migration conn, direction
      @connection = conn
      if respond_to?(:change)
        if direction == :down
          revert { change }
        else
          change
        end
      else
        contentedly { send(direction) }
      end
    ensure
      @connection = nil
    end

    def down
      raise ActiveRecord::IrreversibleMigration
    end

    def update_machine_output
      Card.search(right: { codename: "machine_output" }).each(&:delete)
    end
  end
end

require "card/migration/core"
