require "decko/application"
require_relative "alias"

# full card -T list, same as decko/rake -T lists
# <cmd>    about                                 # List versions of all Rails frameworks and the environment
# <cmd>    action_mailbox:ingress:exim           # Relay an inbound email from Exim to Action Mailbox (URL and INGRESS_PASSWORD required)
# <cmd>    action_mailbox:ingress:postfix        # Relay an inbound email from Postfix to Action Mailbox (URL and INGRESS_PASSWORD required)
# <cmd>    action_mailbox:ingress:qmail          # Relay an inbound email from Qmail to Action Mailbox (URL and INGRESS_PASSWORD required)
# <cmd>    action_mailbox:install                # Copy over the migration
# <cmd>    action_text:install                   # Copy over the migration, stylesheet, and JavaScript files
# <cmd>    active_storage:install                # Copy over the migration needed to the application
# <cmd>    app:template                          # Applies the template supplied by LOCATION=(/path/to/template) or URL
# <cmd>    app:update                            # Update configs and some other initially generated files (or use just update:configs or update:bin)
# <cmd>    assets:clean[keep]                    # Remove old compiled assets
# <cmd>    assets:clobber                        # Remove compiled assets
# <cmd>    assets:environment                    # Load asset compile environment
# <cmd>    assets:precompile                     # Compile all the assets named in config.assets.precompile
# <cmd>    cache_digests:dependencies            # Lookup first-level dependencies for TEMPLATE (like messages/show or comments/_comment.html)
# <cmd>    cache_digests:nested_dependencies     # Lookup nested dependencies for TEMPLATE (like messages/show or comments/_comment.html)
# <cmd>    card:add                              # add a new card to import data
# <cmd>    card:add_remote                       # register remote for importing card data
# <cmd>    card:clean                            # remove unneeded cards, acts, actions, changes, and references
# <cmd>    card:clean_machines                   # clean machine output directory
# <cmd>    card:create:codefile                  # create folders and files for scripts, styles or haml
# <cmd>    card:create:haml                      # create folders and files for haml
# <cmd>    card:create:script                    # create folders and files for script
# <cmd>    card:create:style                     # create folders and files for stylesheet
# <cmd>    card:dump                             # dump card fixtures / dump db to bootstrap fixtures
# <cmd>    card:fixtures:load                    # Load fixtures into the current environment's database
# <cmd>    card:grab:deep_pull                   # add card and all nested cards to import data
# <cmd>    card:grab:deep_pull_items             # add nested cards to import data (not the card itself)
# <cmd>    card:grab:pull                        # add card to import data
# <cmd>    card:grab:pull_export                 # add items of the export card to import data
# <cmd>    card:merge:merge                      # merge import card data that was updated since the last push into the the database
# <cmd>    card:merge:merge_all                  # merge all import card data into the the database
# <cmd>    card:migrate                          # migrate structure and cards
# <cmd>    card:migrate:assume_card_migrations   # insert existing card migrations into schema_migrations_cards to avoid re-migrating
# <cmd>    card:migrate:cards                    # migrate cards
# <cmd>    card:migrate:core_cards               # migrate core cards
# <cmd>    card:migrate:deck_cards               # migrate deck cards
# <cmd>    card:migrate:deck_structure           # migrate deck structure
# <cmd>    card:migrate:redo                     # Redo the deck cards migration given by VERSION
# <cmd>    card:migrate:stamp[type]              # write the version to a file (not usually called directly)
# <cmd>    card:migrate:structure                # migrate structure
# <cmd>    card:refresh_machine_output           # refresh machine output
# <cmd>    card:reset_cache                      # reset cache
# <cmd>    card:reset_machine_output             # reset machine output
# <cmd>    card:reset_tmp                        # reset to empty tmp directory
# <cmd>    card:seed:clear                       # empty the card tables
# <cmd>    card:seed:emergency:rescue_watchers   # rescue watchers
# <cmd>    card:seed:load                        # Load seed data into database
# <cmd>    card:seed:reseed                      # clear and load fixtures with existing tables
# <cmd>    card:supplement                       # add test data
# <cmd>    card:update                           # update decko gems and database / reseed, migrate, re-clean, and re-dump
# <cmd>    cucumber                              # Alias for cucumber:ok
# <cmd>    cucumber:all                          # Run all features
# <cmd>    cucumber:ok                           # Run features that should pass
# <cmd>    cucumber:rerun                        # Record failing features and run only them if any exist
# <cmd>    cucumber:wip                          # Run features that are being worked on
# <cmd>    db:create                             # Creates the database from DATABASE_URL or config/database.yml for the current RAILS_ENV (use db:create:all to create all databases in the config). Without RAILS_ENV or when RAILS_ENV is development, it defaults to creating the development and test databases
# <cmd>    db:drop                               # Drops the database from DATABASE_URL or config/database.yml for the current RAILS_ENV (use db:drop:all to drop all databases in the config). Without RAILS_ENV or when RAILS_ENV is development, it defaults to dropping the development and test databases
# <cmd>    db:environment:set                    # Set the environment value for the database
# <cmd>    db:fixtures:load                      # Loads fixtures into the current environment's database
# <cmd>    db:migrate                            # Migrate the database (options: VERSION=x, VERBOSE=false, SCOPE=blog)
# <cmd>    db:migrate:status                     # Display status of migrations
# <cmd>    db:prepare                            # Runs setup if database does not exist, or runs migrations if it does
# <cmd>    db:rollback                           # Rolls the schema back to the previous version (specify steps w/ STEP=n)
# <cmd>    db:schema:cache:clear                 # Clears a db/schema_cache.yml file
# <cmd>    db:schema:cache:dump                  # Creates a db/schema_cache.yml file
# <cmd>    db:schema:dump                        # Creates a db/schema.rb file that is portable against any DB supported by Active Record
# <cmd>    db:schema:load                        # Loads a schema.rb file into the database
# <cmd>    db:seed                               # Loads the seed data from db/seeds.rb
# <cmd>    db:seed:replant                       # Truncates tables of each database for current environment and loads the seeds
# <cmd>    db:setup                              # Creates the database, loads the schema, and initializes with the seed data (use db:reset to also drop the database first)
# <cmd>    db:structure:dump                     # Dumps the database structure to db/structure.sql
# <cmd>    db:structure:load                     # Recreates the databases from the structure.sql file
# <cmd>    db:version                            # Retrieves the current schema version number
# <cmd>    decko:dump                            # dump card fixtures
# <cmd>    decko:migrate                         # migrate structure and cards
# <cmd>    decko:migrate:assume_card_migrations  # insert existing card migrations into schema_migrations_cards to avoid re-migrating
# <cmd>    decko:migrate:cards                   # migrate cards
# <cmd>    decko:migrate:core_cards              # migrate core cards
# <cmd>    decko:migrate:deck_cards              # migrate deck cards
# <cmd>    decko:migrate:deck_structure          # migrate deck structure
# <cmd>    decko:migrate:redo                    # Redo the deck cards migration given by VERSION
# <cmd>    decko:migrate:stamp[type]             # write the version to a file (not usually called directly)
# <cmd>    decko:migrate:structure               # migrate structure
# <cmd>    decko:refresh_machine_output          # refresh machine output
# <cmd>    decko:reset_cache                     # reset cache
# <cmd>    decko:reset_machine_output            # reset machine output
# <cmd>    decko:reset_tmp                       # reset to empty tmp directory
CARD_TASKS =
  [
    :dump,
    :migrate,
    { migrate: [:assume_card_migrations, :structure, :deck_structure,
        :cards, :core_cards, :deck_cards, :redo, :stamp] },
    :refresh_machine_output,
    :reset_cache,
    :reset_machine_output,
    :reset_tmp,
    :seed,
    { seed: [:clear, :load, :reseed] },
    :supplement,
    :update
  ]

link_task CARD_TASKS, from: :decko, to: :card

decko_namespace = namespace :decko do
  desc "update decko gems and database"
  task :update do
    failing_loudly "decko update" do
      ENV["NO_RAILS_CACHE"] = "true"
      Rake::Task["card:migrate"].invoke
      Rake::Task["card:reset_tmp"].invoke
      Card::Cache.reset_all
      decko_namespace["update_assets_symlink"].invoke
    end
  end

  desc "set symlink for assets"
  task update_assets_symlink: :environment do
    prepped_asset_path do |assets_path|
      Cardio::Mod.dirs.each_assets_path do |mod, target|
        link = File.join assets_path, mod
        FileUtils.rm_rf link
        FileUtils.ln_s target, link, force: true
      end
    end
  end

  def prepped_asset_path
    return if Rails.root.to_s == Decko.gem_root # inside decko gem
    assets_path = File.join Rails.public_path, "assets"
    if File.symlink?(assets_path) || !File.directory?(assets_path)
      FileUtils.rm_rf assets_path
      FileUtils.mkdir assets_path
    end
    yield assets_path
  end
end

def version
  ENV["VERSION"] ? ENV["VERSION"].to_i : nil
end
