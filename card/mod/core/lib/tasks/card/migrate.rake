
namespace :card do
  desc "migrate structure and cards"
  task migrate: :environment do
    ENV["NO_RAILS_CACHE"] = "true"
    stamp = ENV["STAMP_MIGRATIONS"]

    puts "running structure migrations"
    Rake::Task["card:migrate:schema"].invoke
    Rake::Task["card:migrate:stamp"].invoke :structure if stamp

    Rake::Task["card:migrate:transform"].execute
    if stamp
      Rake::Task["card:migrate:stamp"].reenable
      Rake::Task["card:migrate:stamp"].invoke :transform
    end

    Card::Cache.reset_all
  end

  namespace :migrate do
    desc "run structure migrations"
    task schema: :environment do
      interpret_env_schema
      without_dumping do
        run_migration :schema
      end
      Rake::Task["db:_dump"].invoke # write schema.rb
      reset_column_information true
    end

    desc "run transform migrations"
    task transform: :environment do
      puts "running transform migrations"
      require "cardio/migration/transform"

      without_dumping do
        prepare_migration
        run_migration :transform
      end
    end

    # desc "migrate deck structure"
    #
    # def migrate_deck_structure
    #   require "cardio/migration/deck_structure"
    #   set_schema_path
    #   Cardio::Schema.migrate :deck, version
    #   Rake::Task["db:_dump"].invoke # write schema.rb
    #   reset_column_information true
    # end

    desc "Redo the deck cards migration given by VERSION."
    task redo: :environment do
      raise "VERSION is required" unless version.present?

      ActiveRecord::Migration.verbose = verbose
      ActiveRecord::SchemaMigration.where(version: version.to_s).delete_all
      run_migration :transform
    end

    # TODO: move this to a method in Cardio::Schema
    desc "write the version to a file (not usually called directly)"
    task :stamp, [:type] => [:environment] do |_t, args|
      interpret_env_schema
      Cardio.config.action_mailer.perform_deliveries = false

      stamp_file = Cardio::Migration.new_for(args[:type]).stamp_path

      Cardio::Migration.new_for(args[:type]).mode do
        version = ActiveRecord::Migrator.current_version
        if version.to_i.positive? && (file = ::File.open(stamp_file, "w"))
          puts ">>  writing version: #{version} to #{stamp_file}"
          file.puts version
        end
      end
    end

    def version
      ENV["VERSION"] ? ENV["VERSION"].to_i : nil
    end
  end
end

private

def interpret_env_schema schema_dir=nil
  schema_dir ||= "#{Cardio.root}/db"
  # schema_dir = "#{Cardio.root}/db"
  # Dir.mkdir schema_dir unless Dir.exist? schema_dir
  ENV["SCHEMA"] ||= "#{schema_dir}/schema.rb"
end

def run_migration type
  verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
  Cardio::Migration.new_for(type).migrate version, verbose
end

def prepare_migration
  interpret_env_schema
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