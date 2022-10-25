require "optparse"

namespace :card do
  desc "Creates the database, loads the schema, initializes seed data, " \
       "and adds symlinks to public directories"
  task setup: %w[db:setup card:mod:symlink]

  desc "Runs migrations, installs mods, and updates symlinks"
  task :update do
    failing_loudly "decko update" do
      ENV["NO_RAILS_CACHE"] = "true"
      # Benchmark.bm do |x|
      [:migrate, :eat, :reset_tmp, :reset_cache,
       "mod:uninstall", "mod:install", "mod:symlink"].each do |task|
        #x.report(task) do
        Rake::Task["card:#{task}"].invoke
        #end
      end
      #end
    end
  end

  desc "Ingests card data from mod yaml"
  task eat: :environment do
    parse_options :eat do
      add_opt :m, :mod, "only eat cards in given mod"
      add_opt :u, :user, "user to credit unless specified (otherwise uses Decko Bot)"
      add_opt :t, :type, "pod type: real, test, or all"
      flag_opt :v, :verbose, "output progress info and error backtraces"
    end
    rake_result(:eat) { Cardio::Mod::Eat.new(**options).up }
  end

  desc "Exports card data to mod yaml"
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

  desc "Resets cache"
  task reset_cache: :environment do
    Card::Cache.reset_all
  end

  desc "reset with an empty tmp directory"
  task :reset_tmp do
    tmp_dir = Cardio.paths["tmp"].first
    if Cardio.paths["tmp"].existent
      Dir.foreach(tmp_dir) do |filename|
        next if filename.match?(/^\./)

        FileUtils.rm_rf File.join(tmp_dir, filename), secure: true
      end
    else
      Dir.mkdir tmp_dir
    end
  end

  desc "Loads seed data"
  task seed: ["db:seed"]

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

  def failing_loudly task
    yield
  rescue StandardError
    # TODO: fix this so that message appears *after* the errors.
    # Solution should ensure that rake still exits with error code 1!
    raise "\n>>>>>> FAILURE! #{task} did not complete successfully." \
          "\n>>>>>> Please address errors and re-run:\n\n\n"
  end
end
