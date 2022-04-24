require "decko/application"
require_relative "alias"

CARD_TASKS =
  [
    { assets: %i[refresh code wipe] },
    :eat,
    :migrate,
    { migrate: %i[cards structure core_cards deck_cards redo stamp] },

    :reset_cache
  ].freeze

link_task CARD_TASKS, from: :decko, to: :card

decko_namespace = namespace :decko do
  # desc "create a decko database from scratch, load initial data"
  # task :seed do
  #   failing_loudly "decko seed" do
  #     seed
  #   end
  # end
  #
  # desc "create a decko database from scratch, load initial data, don't reset the cache"
  # task :seed_without_reset do
  #   # This variant is needed to generate test databases for decks
  #   # with custom codenames.
  #   # The cache reset loads the environment. That tends to fail
  #   # because of missing codenames that are added after the intial decko seed.
  #   seed with_cache_reset: false
  # end

  desc "clear and load fixtures with existing tables"
  task reseed: :environment do
    ENV["SCHEMA"] ||= "#{Cardio.gem_root}/db/schema.rb"

    decko_namespace["clear"].invoke
    decko_namespace["load"].invoke
  end

  desc "empty the card tables"
  task :clear do
    conn = ActiveRecord::Base.connection

    puts "delete all data in bootstrap tables"
    Cardio::Seed::TABLES.each do |table|
      conn.delete "delete from #{table}"
    end
  end

  # desc "Load seed data into database"
  # task :load do
  #   decko_namespace["load_without_reset"].invoke
  #   puts "reset cache"
  #   system "bundle exec rake decko:reset_cache" # needs loaded environment
  # end

  # desc "Load seed data into database but don't reset cache"
  # task :load_without_reset do
  #   require "decko/engine"
  #   # puts "update card_migrations"
  #   # decko_namespace["assume_card_migrations"].invoke
  #
  #   if Rails.env == "test" && !ENV["GENERATE_FIXTURES"]
  #     puts "loading test fixtures"
  #     Rake::Task["db:fixtures:load"].invoke
  #   else
  #     puts "loading seed data"
  #     # db:seed checks for pending migrations. We don't want that because
  #     # as part of the seeding process we update the migration table
  #     ActiveRecord::Tasks::DatabaseTasks.load_seed
  #     # :Rake::Task["db:seed"].invoke
  #   end
  #
  #   puts "set symlink for assets"
  #   decko_namespace["card:mod:symlink"].invoke
  # end

  desc "reset with an empty tmp directory"
  task :reset_tmp do
    tmp_dir = Decko.paths["tmp"].first
    if Decko.paths["tmp"].existent
      Dir.foreach(tmp_dir) do |filename|
        next if filename.starts_with? "."

        FileUtils.rm_rf File.join(tmp_dir, filename), secure: true
      end
    else
      Dir.mkdir tmp_dir
    end
  end

  desc "update decko gems and database"
  task :update do
    failing_loudly "decko update" do
      ENV["NO_RAILS_CACHE"] = "true"
      decko_namespace["migrate"].invoke
      decko_namespace["reset_tmp"].invoke
      Card::Cache.reset_all
      Rake::Task["card:mod:uninstall"].invoke
      Rake::Task["card:mod:install"].invoke
      Rake::Task["card:mod:symlink"].invoke
    end
  end

  %i[list symlink missing uninstall install].each do |task|
    alias_task "mod:#{task}", "card:mod:#{task}"
  end
  alias_task :migrate, "card:migrate"

  desc "insert existing card migrations into schema_migrations_cards " \
       "to avoid re-migrating"
  task :assume_card_migrations do
    require "decko/engine"
    Cardio::Schema.assume_migrated_upto_version :core_cards
  end

  # def seed with_cache_reset: true
  #   ENV["SCHEMA"] ||= "#{Cardio.gem_root}/db/schema.rb"
  #   # FIXME: this should be an option, but should not happen on standard creates!
  #   begin
  #     Rake::Task["db:drop"].invoke
  #   rescue StandardError
  #     puts "not dropped"
  #   end
  #
  #   puts "creating"
  #   Rake::Task["db:create"].invoke
  #
  #   puts "loading schema"
  #   Rake::Task["db:schema:load"].invoke
  #
  #   load_task = "decko:load"
  #   load_task << "_without_reset" unless with_cache_reset
  #   Rake::Task[load_task].invoke
  # end
end

def failing_loudly task
  yield
rescue StandardError
  # TODO: fix this so that message appears *after* the errors.
  # Solution should ensure that rake still exits with error code 1!
  raise "\n>>>>>> FAILURE! #{task} did not complete successfully." \
        "\n>>>>>> Please address errors and re-run:\n\n\n"
end

def version
  ENV["VERSION"] ? ENV["VERSION"].to_i : nil
end
