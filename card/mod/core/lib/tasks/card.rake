require "optparse"

namespace :card do
  desc "ingest card data from mod yaml"
  task eat: :environment do
    parse_options :eat do
      add_opt :m, :mod, "only merge cards in given mod"
      add_opt :e, :env, "environment of yaml source (default is current env)"
      add_opt :u, :user, "user to credit unless specified (otherwise uses Decko Bot)"
      flag_opt :v, :verbose, "progress info and error backtraces"
    end
    rake_result(:eat) { Cardio::Mod::Eat.new(**options).up }
  end

  desc "export card data to mod yaml"
  task sow: :environment do
    parse_options :sow do
      add_opt :n, :name, "export card with name/mark (handles : and ~ prefixes)"
      flag_opt :i, :items, "also export card items (with -n)"
      flag_opt :o, :only_items, "also export card items (with -n)", items: :only
      add_opt :c, :cql, "export cards found by CQL (in JSON format)"
      add_opt :m, :mod, "output yaml to data/environment.yml file in mod"
      add_opt :e, :env, "environment to dump to (default is current env)"
      add_opt :t, :field_tags, "comma-separated list of field tag marks"
    end
    rake_result(:sow) { Cardio::Mod::Sow.new(**options).out }
  end

  desc "reset cache"
  task reset_cache: :environment do
    Card::Cache.reset_all
  end

  task seed: ["db:seed"]
  task setup: %w[db:setup card:mod:symlink]

  desc "update decko gems and database"
  task :update do
    failing_loudly "decko update" do
      ENV["NO_RAILS_CACHE"] = "true"
      Rake::Task["decko:migrate"].invoke
      Rake::Task["decko:reset_tmp"].invoke
      Card::Cache.reset_all
      Rake::Task["card:mod:uninstall"].invoke
      Rake::Task["card:mod:install"].invoke
      Rake::Task["card:mod:symlink"].invoke
    end
  end

  def options
    @options ||= {}
  end

  def rake_result task
    result = yield
    if result == :success
      exit 0 if @options.present? # otherwise rake tries to run the arguments as tasks
    else
      puts "ERROR in card #{task}:\n  #{result}".red
      exit 1
    end
  end

  def flag_opt letter, key, desc, hash=nil
    hash ||= { key => true }
    op.on("-#{letter}", "--#{key.to_s.tr '_', '-'}", desc) { options.merge! hash }
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
