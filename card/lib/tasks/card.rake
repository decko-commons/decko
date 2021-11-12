require "optparse"

namespace :card do
  desc "ingest card data from mod yaml"
  task eat: :environment do
    parse_options :in do
      add_opt :m, :mod, "only merge cards in given mod"
      add_opt :e, :env, "environment of yaml source (default is current env)"
      add_opt :u, :user, "user to credit unless specified (otherwise uses Decko Bot)"
    end
    Cardio::Mod::Eat.new(**options).up
    exit 0
  end

  desc "export card data to mod yaml"
  task barf: :environment do
    parse_options :out do
      add_opt :n, :name, "export card with name/mark (handles : and ~ prefixes)"
      item_opt :i, :items, "also export card items (with -n)", true
      item_opt :o, :only_items, "also export card items (with -n)", :only
      add_opt :c, :cql, "export cards found by CQL (in JSON format)"
      add_opt :m, :mod, "output yaml to data/environment.yml file in mod"
      add_opt :e, :env, "environment to dump to (default is current env)"
      add_opt :t, :field_tags, "comma-separated list of field tag marks"
    end
    result = Cardio::Mod::Barf.new(**options).out
    exit 0 if result == :success

    puts "ERROR in card:barf\n  #{result}".red
    exit 1
  end

  desc "reset cache"
  task reset_cache: :environment do
    Card::Cache.reset_all
  end

  def options
    @options ||= {}
  end

  def item_opt letter, key, desc, val
    op.on("-#{letter}", "--#{key.to_s.tr '_', '-'}", desc) { options[:items] = val }
  end

  def add_opt letter, key, desc
    op.on "-#{letter}", "--#{key.to_s.tr '_', '-'} #{key.to_s.upcase}", desc do |val|
      options[key] = val
    end
  end

  def op
    @op ||= OptionParser.new
  end

  def parse_options task
    op.banner = "Usage: rake card:#{task} -- [options]"
    yield if block_given?
    args = op.order!(ARGV) {}
    # args << "-h" if args.empty?
    op.parse! args
  end
end
