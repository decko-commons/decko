def run_card_migration core_or_deck
  prepare_migration
  verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
  Cardio::Schema.migrate core_or_deck, version, verbose
end

def prepare_migration
  Card::Cache.reset_all
  ENV["SCHEMA"] ||= "#{Cardio.gem_root}/db/schema.rb"
  Card::Cache.reset_all
  Card.config.action_mailer.perform_deliveries = false
  Card.reset_column_information
  # this is needed in production mode to insure core db
  Card::Reference.reset_column_information
  # structures are loaded before schema_mode is set
end

# @param mod [Boolean] if true reset column information for models defined in
#   in mods in the deck
def reset_column_information mod=false
  Rails.application.eager_load!
  load_mod_lib if mod && !ENV["NO_CARD_LOAD"]
  Cardio::Record.descendants.each(&:reset_column_information)
end

# FIXME: too general
# intent is to find Record classes; this gets a lot more.
def load_mod_lib
  Dir.glob(Cardio.root.join("mod/*/lib/*.rb")).sort.each { |x| require x }
end

def without_dumping
  ActiveRecord::Base.dump_schema_after_migration = false
  yield
end

namespace :card do
  desc "migrate structure and cards"
  task migrate: :environment do
    ENV["NO_RAILS_CACHE"] = "true"
    ENV["SCHEMA"] ||= "#{Cardio.gem_root}/db/schema.rb"

    stamp = ENV["STAMP_MIGRATIONS"]

    puts "migrating structure"
    Rake::Task["card:migrate:structure"].invoke
    Rake::Task["card:migrate:stamp"].invoke :structure if stamp

    puts "migrating deck structure"
    Rake::Task["card:migrate:deck_structure"].execute
    if stamp
      Rake::Task["card:migrate:stamp"].reenable
      Rake::Task["card:migrate:stamp"].invoke :core_cards
    end

    puts "migrating core cards"
    Card::Cache.reset_all
    # not invoke because we don't want to reload environment
    Rake::Task["card:migrate:core_cards"].execute
    if stamp
      Rake::Task["card:migrate:stamp"].reenable
      Rake::Task["card:migrate:stamp"].invoke :core_cards
    end

    puts "migrating deck cards"
    # not invoke because we don't want to reload environment
    Rake::Task["card:migrate:deck_cards"].execute
    if stamp
      Rake::Task["card:migrate:stamp"].reenable
      Rake::Task["card:migrate:stamp"].invoke :deck_cards
    end

    Card::Cache.reset_all
  end

  namespace :migrate do
    desc "migrate cards"
    task cards: %i[core_cards deck_cards]

    desc "migrate structure"
    task structure: :environment do
      ENV["SCHEMA"] ||= "#{Cardio.gem_root}/db/schema.rb"
      without_dumping do
        Cardio::Schema.migrate :structure, version
      end
    end

    desc "migrate core cards"
    task core_cards: :environment do
      without_dumping do
        require "cardio/migration/core"
        run_card_migration :core_cards
      end
    end

    desc "migrate deck structure"
    task deck_structure: :environment do
      migrate_deck_structure
      reset_column_information
    end

    def migrate_deck_structure
      require "cardio/migration/deck_structure"
      set_schema_path
      Cardio::Schema.migrate :deck, version
      Rake::Task["db:_dump"].invoke # write schema.rb
      reset_column_information true
    end

    def set_schema_path
      schema_dir = "#{Cardio.root}/db"
      Dir.mkdir schema_dir unless Dir.exist? schema_dir
      ENV["SCHEMA"] = "#{schema_dir}/schema.rb"
    end

    desc "migrate deck cards"
    task deck_cards: :environment do
      require "cardio/migration"
      run_card_migration :deck_cards
    end

    desc "Redo the deck cards migration given by VERSION."
    task redo: :environment do
      version = ENV["VERSION"] ? ENV["VERSION"].to_i : nil
      verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
      raise "VERSION is required" unless version

      ActiveRecord::Migration.verbose = verbose
      ActiveRecord::SchemaMigration.where(version: version.to_s).delete_all
      Cardio::Schema.migrate :deck_cards, version
    end

    # maybe we should move this to a method?
    desc "write the version to a file (not usually called directly)"
    task :stamp, [:type] => [:environment] do |_t, args|
      ENV["SCHEMA"] ||= "#{Cardio.gem_root}/db/schema.rb"
      Cardio.config.action_mailer.perform_deliveries = false

      stamp_file = Cardio::Schema.stamp_path args[:type]

      Cardio::Schema.mode args[:type] do
        version = ActiveRecord::Migrator.current_version
        if version.to_i.positive? && (file = ::File.open(stamp_file, "w"))
          puts ">>  writing version: #{version} to #{stamp_file}"
          file.puts version
        end
      end
    end
  end
end
