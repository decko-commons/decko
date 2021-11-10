require "optparse"

namespace :card do
  desc "import card data from mod yaml"
  task in: :environment do
    parse_options :in do
      add_opt :m, :mod, "only merge cards in given mod"
      add_opt :e, :env, "environment of yaml source (default is current env)"
    end
    Cardio::Mod::InData.new(**options).merge
    exit 0
  end

  desc "export card data to mod yaml"
  task out: :environment do
    parse_options :out do
      add_opt :n, :name, "export card with name/mark (handles : and ~ prefixes)"
      op.on "-i", "--items", "also export card items (with -n)" do
        options[:items] = true
      end
      op.on "-o", "--only-items", "only export card items (with -n)" do
        options[:items] = :only
      end
      add_opt :c, :cql, "export cards found by CQL (in JSON format)"
      add_opt :m, :mod, "output yaml to data/environment.yml file in mod"
      add_opt :e, :env, "environment to dump to (default is current env)"
      add_opt :s, :subfields, "comma-separated list of field codes"
    end
    result = Cardio::Mod::OutData.new(**options).out
    exit 0 if result == :success

    puts "ERROR in card:out\n  #{result}".red
    exit 1
  end

  desc "reset cache"
  task reset_cache: :environment do
    Card::Cache.reset_all
  end

  def options
    @options ||= {}
  end

  def add_opt letter, key, desc
    op.on "-#{letter}", "--#{key} #{key.to_s.upcase}", desc do |val|
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
    args << "-h" if args.empty?
    op.parse! args
  end
end
