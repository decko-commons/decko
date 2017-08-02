require "decko/application"

DECKO_SEED_TABLES = %w( cards card_actions card_acts card_changes
                       card_references ).freeze
DECKO_SEED_PATH = File.join(
  ENV["DECKO_SEED_REPO_PATH"] || [Cardio.gem_root, "db", "seed"], "new"
)

namespace :decko do
  desc "create a decko database from scratch, load initial data"
  task :seed do
    ENV["SCHEMA"] ||= "#{Cardio.gem_root}/db/schema.rb"
    puts "dropping"
    # FIXME: this should be an option, but should not happen on standard
    # creates!
    begin
      Rake::Task["db:drop"].invoke
    rescue
      puts "not dropped"
    end

    puts "creating"
    Rake::Task["db:create"].invoke

    puts "loading schema"
    Rake::Task["db:schema:load"].invoke

    Rake::Task["decko:load"].invoke
  end

  desc "clear and load fixtures with existing tables"
  task reseed: :environment do
    ENV["SCHEMA"] ||= "#{Cardio.gem_root}/db/schema.rb"

    Rake::Task["decko:clear"].invoke

    Rake::Task["decko:load"].invoke
  end

  desc "empty the card tables"
  task :clear do
    conn = ActiveRecord::Base.connection

    puts "delete all data in bootstrap tables"
    DECKO_SEED_TABLES.each do |table|
      conn.delete "delete from #{table}"
    end
  end

  desc "Load bootstrap data into database"
  task :load do
    require "decko/engine"
    puts "update card_migrations"
    Rake::Task["decko:assume_card_migrations"].invoke

    if Rails.env == "test" && !ENV["GENERATE_FIXTURES"]
      puts "loading test fixtures"
      Rake::Task["db:fixtures:load"].invoke
    else
      puts "loading bootstrap"
      Rake::Task["decko:bootstrap:load"].invoke
    end

    puts "set symlink for assets"
    Rake::Task["decko:update_assets_symlink"].invoke

    puts "reset cache"
    system "bundle exec rake decko:reset_cache" # needs loaded environment
  end

  desc "update decko gems and database"
  task :update do
    ENV["NO_RAILS_CACHE"] = "true"
    # system 'bundle update'
    if Decko.paths["tmp"].existent
      FileUtils.rm_rf Decko.paths["tmp"].first, secure: true
    end
    Dir.mkdir Decko.paths["tmp"].first
    Rake::Task["decko:migrate"].invoke
    # FIXME: remove tmp dir / clear cache
    puts "set symlink for assets"
    Rake::Task["decko:update_assets_symlink"].invoke
  end

  desc "reset cache"
  task reset_cache: :environment do
    Card::Cache.reset_all
    Card.reset_all_machines
  end

  desc "set symlink for assets"
  task :update_assets_symlink do
    assets_path = File.join(Rails.public_path, "assets")
    if Rails.root.to_s != Decko.gem_root && !File.exist?(assets_path)
      FileUtils.rm assets_path if File.symlink? assets_path
      FileUtils.ln_s(Decko::Engine.paths["gem-assets"].first, assets_path)
    end
  end

  desc "migrate structure and cards"
  task migrate: :environment do
    ENV["NO_RAILS_CACHE"] = "true"
    ENV["SCHEMA"] ||= "#{Cardio.gem_root}/db/schema.rb"

    stamp = ENV["STAMP_MIGRATIONS"]

    puts "migrating structure"
    Rake::Task["decko:migrate:structure"].invoke
    Rake::Task["decko:migrate:stamp"].invoke :structure if stamp

    puts "migrating core cards"
    Card::Cache.reset_all
    # not invoke because we don't want to reload environment
    Rake::Task["decko:migrate:core_cards"].execute
    if stamp
      Rake::Task["decko:migrate:stamp"].reenable
      Rake::Task["decko:migrate:stamp"].invoke :core_cards
    end

    puts "migrating deck cards"
    # not invoke because we don't want to reload environment
    Rake::Task["decko:migrate:deck_cards"].execute
    if stamp
      Rake::Task["decko:migrate:stamp"].reenable
      Rake::Task["decko:migrate:stamp"].invoke :deck_cards
    end

    Card::Cache.reset_all
  end

  desc "insert existing card migrations into schema_migrations_cards to avoid re-migrating"
  task :assume_card_migrations do
    require "decko/engine"

    Cardio.assume_migrated_upto_version :core_cards
  end

  namespace :emergency do
    task rescue_watchers: :environment do
      follower_hash = Hash.new { |h, v| h[v] = [] }

      Card.where("right_id" => 219).each do |watcher_list|
        watcher_list.include_set_modules
        next unless watcher_list.left
        watching = watcher_list.left.name
        watcher_list.item_names.each do |user|
          follower_hash[user] << watching
        end
      end

      Card.search(right: { codename: "following" }).each do |following|
        Card::Auth.as_bot do
          following.update_attributes! content: ""
        end
      end

      follower_hash.each do |user, items|
        next unless (card = Card.fetch(user)) && card.account
        Card::Auth.as(user) do
          following = card.fetch trait: "following", new: {}
          following.items = items
        end
      end
    end
  end
end

def version
  ENV["VERSION"] ? ENV["VERSION"].to_i : nil
end
