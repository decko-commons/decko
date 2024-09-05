
namespace :card do
  desc "migrate structure and cards"
  task migrate: :environment do
    ENV["NO_RAILS_CACHE"] = "true"

    Rake::Task["card:migrate:schema"].invoke
    Rake::Task["card:migrate:transform"].execute
    Card::Cache.reset_all
  end

  namespace :migrate do
    desc "run structure migrations"
    task schema: :environment do
      puts "running schema migrations"

      interpret_env_schema
      without_dumping do
        run_migration :schema
      end
      Rake::Task["db:schema:dump"].invoke # write schema.rb
      reset_column_information true
    end

    desc "run transform migrations"
    task transform: :environment do
      puts "running transform migrations"

      without_dumping do
        prepare_migration
        run_migration :transform
      end
    end

    desc "Redo the transform migration given by VERSION."
    task redo: :environment do
      raise "VERSION is required" unless version.present?

      ActiveRecord::Migration.verbose = verbose
      ActiveRecord::SchemaMigration.where(version: version.to_s).delete_all
      run_migration :transform
    end

    desc "write the version to a file (not usually called directly)"
    task :stamp, [:type] => [:environment] do |_t, args|
      interpret_env_schema
      Cardio.config.action_mailer.perform_deliveries = false
      Cardio::Migration.new_for(args[:type]).stamp
    end

    task port: :environment do
      Cardio::Migration.port_all
    end

    task recode: :environment do
      Cardio::Mod.dirs.subpaths("data", "recode.yml").each_value do |path|
        YAML.load_file(path).each do |oldcode, newcode|
          Card::Codename.recode oldcode, newcode
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
  Cardio::Migration.new_for(type).run version, verbose
  stamp_migration type
end

def stamp_migration type
  return unless ENV["STAMP_MIGRATIONS"]

  task = Rake::Task["card:migrate:stamp"]
  task.reenable
  task.invoke type
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
  ActiveRecord.dump_schema_after_migration = false
  yield
end
