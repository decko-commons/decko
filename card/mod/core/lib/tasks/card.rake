require "optparse"

namespace :card do
  desc "Creates the database, loads the schema, initializes seed data, " \
       "and adds symlinks to public directories"
  task setup: %w[db:setup card:mod:symlink]
  # task setup: %w[db:setup card:update] # can't do update yet, because it overrides
  # coded assets, which breaks testing

  desc "Runs migrations, installs mods, and updates symlinks"
  task :update do
    failing_loudly "decko update" do
      ENV["NO_RAILS_CACHE"] = "true"
      run_tasks ["migrate:port", "migrate:schema", "migrate:recode",
                 :eat, "migrate:transform",
                 "mod:uninstall", "mod:install", "mod:symlink", :reset] # , true
    end
  end

  def run_tasks tasks, with_benchmark: false
    if with_benchmark
      require "benchmark"
      Benchmark.bm do |x|
        x.report("total") do
          tasks.each do |task|
            x.report(task) { Rake::Task["card:#{task}"].invoke }
          end
        end
      end
    else
      tasks.each do |task|
        Rake::Task["card:#{task}"].invoke
      end
    end
  end

  desc "Ingests card data from mod yaml"
  task eat: :environment do
    run_with_options :eat, Cardio::Mod::Eat, "eating" do
      add_opt :m, :mod, "only eat cards in given mod"
      add_opt :n, :name, "only eat card with name (handles : for codenames)"
      add_opt :u, :user, "user to credit unless specified (default is Decko Bot)"
      add_opt :p, :podtype, "pod type: real, test, or all " \
                            "(defaults to all in test env, otherwise real)"
      add_opt :e, :env, "environment (test, production, etc)"
      flag_opt :v, :verbose, "output progress info and error backtraces"
    end
  end

  def args_without_env_arg
    env_index = ARGV.find_index { |entry| %w[-e --env].include?(entry) }
    args =
      if env_index
        ARGV[1..].select.with_index do |_, index|
          (index != env_index - 1) && (index != env_index)
        end
      else
        ARGV[1..]
      end
    args&.join " "
  end

  def adjust_environment options, args_without_env, task, task_message
    if (env = options.delete(:env))
      command = "env RAILS_ENV=#{env} bundle exec rake card:#{task} #{args_without_env}"
      puts command.yellow
      success = system command
      exit success # to avoid that rake tries to run the arguments as rake tasks
    else
      puts task_message
      yield
    end
  end

  def run_with_options task_name, task_class, start_message, &block
    args_without_env = args_without_env_arg
    parse_options task_name, &block
    adjust_environment options, args_without_env, task_name, start_message do
      rake_result(task_name) { task_class.new(**options).run }
    end
  end

  desc "Exports card data to mod yaml"
  task sow: :environment do
    run_with_options :sow, Cardio::Mod::Sow, "sowing" do
      add_opt :n, :name, "export card with name/mark (handles : and ~ prefixes)"
      add_opt :r, :remote, "export card from remote deck (with -n)"
      flag_opt :i, :items, "also export card items (with -n)"
      flag_opt :o, :only_items, "only export card items (with -n)", items: :only
      add_opt :c, :cql, "export cards found by CQL (in JSON format)"
      add_opt_without_shortcut :url, "source card details from url"
      add_opt :m, :mod, "output yaml file in mod"
      add_opt :p, :podtype, "podtype to dump (real or test. default based on current env)"
      add_opt :t, :field_tags, "comma-separated list of field tag marks"
      add_opt :e, :env, "environment (test, production, etc)"
    end
  end

  desc "Clears both cache and tmpfiles"
  task reset: :environment do
    puts "resetting"
    Card::Cache.shared_on!

    parse_options :reset do
      flag_opt :c, :cache, "cache only"
      flag_opt :t, :tmpfiles, "tmpfiles only"
    end
    reset_tmpfiles unless options[:cache]
    Card::Cache.reset_all unless options[:tmpfiles]
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
    op.on "-#{letter}", key_to_option_description(key), desc do |val|
      options[key] = val
    end
  end

  def add_opt_without_shortcut key, desc
    op.on key_to_option_description(key), desc do |val|
      options[key] = val
    end
  end

  def key_to_option_description key
    "--#{key.to_s.tr '_', '-'} #{key.to_s.upcase}"
  end

  def op
    @op ||= OptionParser.new
  end

  def parse_options task
    op.banner = "Usage: card #{task} [options]"
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

  def reset_tmpfiles
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
end
