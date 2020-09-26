require "rails/generators/app_base"

class DeckoGenerator < Rails::Generators::AppBase
  # class DeckoGenerator < Rails::Generators::AppGenerator

  source_root File.expand_path("../templates", __FILE__)

  class_option "mod-dev",
               type: :boolean, aliases: "-m", default: false, group: :runtime,
               desc: "Prepare deck for mod development"

  class_option "core-dev",
               type: :boolean, aliases: "-c", default: false, group: :runtime,
               desc: "Prepare deck for core development"

  class_option "gem-path",
               type: :string, aliases: "-g", default: "", group: :runtime,
               desc: "Path to local decko repository " \
                     "(Default, use env DECKO_GEM_PATH)"

  class_option :database,
               type: :string, aliases: "-d", default: "mysql",
               desc: "Preconfigure for selected database " \
                     "(options: #{DATABASES.join('/')})"

  class_option "interactive",
               type: :boolean, aliases: "-i", default: false, group: :runtime,
               desc: "Prompt with dynamic installation options"

  public_task :set_default_accessors!
  public_task :create_root

  ## should probably eventually use rails-like AppBuilder approach,
  # but this is a first step.
  def dev_setup
    determine_gemfile_gem_path
    @include_jasmine_engine = false
    if options["core-dev"]
      core_dev_setup
    elsif options["mod-dev"]
      mod_dev_setup
    end
  end

  def rakefile
    template "Rakefile"
  end

  #  def readme
  #    copy_file "README", "README.rdoc"
  #  end

  def mod
    empty_directory_with_keep_file "mod"
  end

  def log
    empty_directory_with_keep_file "log"
  end

  def files
    empty_directory_with_keep_file "files"
  end

  def tmp
    empty_directory "tmp"
  end

  def gemfile
    template "Gemfile"
  end

  def configru
    template "config.ru"
  end

  def gitignore
    copy_file "gitignore", ".gitignore"
  end

  def config
    empty_directory "config"

    inside "config" do
      template "application.rb"
      template "routes.erb", "routes.rb"
      template "environment.rb"
      template "boot.rb"
      template "databases/#{options[:database]}.yml", "database.yml"
      template "cucumber.yml" if options["core-dev"]
      template "initializers/cypress_on_rails.rb" if options["core-dev"]
    end
  end

  def public
    empty_directory "public"

    inside "public" do
      template "robots.txt"
      empty_directory "files"

      inside "files" do
        template "htaccess", ".htaccess"
      end
    end
  end

  def script
    directory "script" do |content|
      "#{shebang}\n" + content
    end
    chmod "script", 0755 & ~File.umask, verbose: false
  end

  public_task :run_bundle

  def seed_data
    if options["interactive"]
      Interactive.new(options, destination_root).run
    else
      puts "Now:
1. Run `cd #{File.basename(destination_root)}` to move your new deck directory
2. Run `decko seed` to seed your database (see db configuration in config/database.yml).
3. Run `decko server` to start your server"
    end
  end

  def database_gemfile_entry
    return [] if options[:skip_active_record]
    gem_name, gem_version = gem_for_database
    msg = "Use #{options[:database]} as the database for Active Record"
    GemfileEntry.version gem_name, gem_version, msg
  end

  def self.banner
    "decko new #{arguments.map(&:usage).join(' ')} [options]"
  end

  protected

  def determine_gemfile_gem_path
    # TODO: rename or split, gem_path points to the source repo,
    # card and decko gems are subdirs
    if (env_gem_path = ENV["DECKO_GEM_PATH"]).present?
      @gemfile_gem_path = %q(#{ENV['DECKO_GEM_PATH']})
      @gem_path = env_gem_path
    else
      @gemfile_gem_path = @gem_path = options["gem-path"]
    end
  end

  def core_dev_setup
    prompt_for_gem_path
    @include_jasmine_engine = true
    @spec_path = @gem_path
    @spec_helper_path = File.join @spec_path, "card", "spec", "spec_helper"

    # ending slash is important in order to load support and step folders
    @features_path = File.join @gem_path, "decko/features/"
    @simplecov_config = "card_core_dev_simplecov_filters"
    shared_dev_setup
    javascript_spec_setup "decko_jasmine"
  end

  def prompt_for_gem_path
    return if @gem_path.present?
    @gemfile_gem_path =
      @gem_path = ask("Enter the path to your local decko gem installation: ")
  end

  def mod_dev_setup
    @spec_path = "mod/"
    @spec_helper_path = "./spec/spec_helper"
    @simplecov_config = "card_simplecov_filters"
    shared_dev_setup
    inside("spec") { template "spec_helper.rb" }
    javascript_spec_setup "deck_jasmine"
  end

  def javascript_spec_setup jasmine_prefix
    inside "spec" do
      template File.join("javascripts", "support", "#{jasmine_prefix}.yml"),
               File.join("javascripts", "support", "jasmine.yml")
    end
  end

  def shared_dev_setup
    @cardio_gem_root = File.join @gem_path, "card"
    @decko_gem_root = File.join @gem_path, "decko"
    empty_directory "spec"
    inside "config" do
      template "puma.rb"
    end
    template "rspec", ".rspec"
    template "simplecov", ".simplecov"
    empty_directory "bin"
    inside "bin" do
      template "spring"
    end
  end

  def mysql_socket
    @mysql_socket ||= [
      "/tmp/mysql.sock",                        # default
      "/var/run/mysqld/mysqld.sock",            # debian/gentoo
      "/var/tmp/mysql.sock",                    # freebsd
      "/var/lib/mysql/mysql.sock",              # fedora
      "/opt/local/lib/mysql/mysql.sock",        # fedora
      "/opt/local/var/run/mysqld/mysqld.sock",  # mac + darwinports + mysql
      "/opt/local/var/run/mysql4/mysqld.sock",  # mac + darwinports + mysql4
      "/opt/local/var/run/mysql5/mysqld.sock",  # mac + darwinports + mysql5
      "/opt/lampp/var/mysql/mysql.sock"         # xampp for linux
    ].find { |f| File.exist?(f) } unless RbConfig::CONFIG["host_os"] =~ /mswin|mingw/
  end

  ### the following is straight from rails and is focused on checking
  # the validity of the app name.needs decko-specific tuning

  def app_name
    @app_name ||= if defined_app_const_base?
                    defined_app_name
                  else
                    File.basename(destination_root)
                  end
  end

  def defined_app_name
    defined_app_const_base.underscore
  end

  def defined_app_const_base
    Rails.respond_to?(:application) && defined?(Rails::Application) &&
      Decko.application.is_a?(Rails::Application) &&
      Decko.application.class.name.sub(/::Application$/, "")
  end

  alias defined_app_const_base? defined_app_const_base

  def app_const_base
    @app_const_base ||= defined_app_const_base ||
                        app_name.gsub(/\W/, "_").squeeze("_").camelize
  end

  alias camelized app_const_base

  def app_const
    @app_const ||= "#{app_const_base}::Application"
  end

  def valid_const?
    if app_const =~ /^\d/
      raise Thor::Error, "Invalid application name #{app_name}. " \
                   "Please give a name which does not start with numbers."
    #    elsif RESERVED_NAMES.include?(app_name)
    #      raise Error, "Invalid application name #{app_name}." \
    # "Please give a name which does not match one of the reserved rails words."
    elsif Object.const_defined?(app_const_base)
      raise Thor::Error, "Invalid application name #{app_name}, " \
                   "constant #{app_const_base} is already in use. " \
                   "Please choose another application name."
    end
  end
end
