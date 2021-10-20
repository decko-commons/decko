require "optparse"

namespace :card do
  def importer
    @importer ||= Cardio::Migration::Import.new Cardio::Migration.data_path
  end

  desc "merge import card data that was updated since the last push into " \
       "the the database"
  task merge: :environment do
    options = {}
    o = OptionParser.new

    #o.banner = "Usage: rake card:merge [options]"
    # o.on("-m MOD", "--mod MOD") { |mod| options[:mod] = mod }
    #args = o.order!(ARGV) {}
    #o.parse! args
    Cardio::Mod::Data.new(**options).merge
    exit 0
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

  desc "reset cache"
  task reset_cache: :environment do
    Card::Cache.reset_all
  end
end
