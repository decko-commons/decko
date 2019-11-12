namespace :card do
  def importer
    @importer ||= Card::Migration::Import.new Card::Migration.data_path
  end

  desc "merge import card data that was updated since the last push into " \
       "the the database"
  task merge: :environment do
    importer.merge
  end

  desc "merge all import card data into the the database"
  task merge_all: :environment do
    importer.merge all: true
  end

  desc "add card to import data"
  task pull: :environment do
    pull_card
  end

  desc "add card and all nested cards to import data"
  task deep_pull: :environment do
    pull_card deep: true
  end

  desc "add nested cards to import data (not the card itself)"
  task deep_pull_items: :environment do
    pull_card items_only: true
  end

  # be rake card:pull_export from=live
  desc "add items of the export card to import data"
  task pull_export: :environment do
    importer.pull "export", items_only: true, remote: ENV["from"]
  end

  desc "add a new card to import data"
  task add: :environment do
    _task, name, type, codename = ARGV
    importer.add_card name: name, type: type || "Basic", codename: codename
    exit
  end

  desc "register remote for importing card data"
  task add_remote: :environment do
    _task, name, url = ARGV
    raise "no name given" unless name.present?
    raise "no url given" unless url.present?

    importer.add_remote name, url
    exit
  end

  def pull_card opts={}
    _task, card = ARGV
    raise "no card given" unless card.present?

    importer.pull card, opts.merge(remote: ENV["from"])
    exit # without exit the card argument is treated as second rake task
  end

  desc "migrate structure and cards"
  task migrate: :environment do
    ENV["NO_RAILS_CACHE"] = "true"
    ENV["SCHEMA"] ||= "#{Cardio.gem_root}/db/schema.rb"

    stamp = ENV["STAMP_MIGRATIONS"]

    puts "migrating structure"
    Rake::Task["card:migrate:structure"].invoke
    Rake::Task["card:migrate:stamp"].invoke :structure if stamp

    puts "migrating core cards"
    Card::Cache.reset_all
    # not invoke because we don't want to reload environment
    Rake::Task["card:migrate:core_cards"].execute
    if stamp
      Rake::Task["card:migrate:stamp"].reenable
      Rake::Task["card:migrate:stamp"].invoke :core_cards
    end

    puts "migrating deck structure"
    Rake::Task["card:migrate:deck_structure"].execute
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

  desc "reset cache"
  task reset_cache: :environment do
    Card::Cache.reset_all
  end

  desc "reset machine output"
  task reset_machine_output: :environment do
    Card.reset_all_machines
  end

  desc "refresh machine output"
  task refresh_machine_output: :environment do
    Card.reset_all_machines
    Card::Auth.as_bot do
      [%i[all script],
       %i[all style],
       %i[script_html5shiv_printshiv]].each do |name_parts|
        Card[*name_parts].update_machine_output
      end
    end
    Card::Cache.reset_all # should not be necessary but breaking without...
  end
end
