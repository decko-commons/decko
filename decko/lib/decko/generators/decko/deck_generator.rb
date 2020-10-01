require "rails/generators/app_base"

module Decko
  module Generators
    class DeckGenerator < Rails::Generators::AppBase
      require "decko/generators/deck_generator/rails_overrides"
      require "decko/generators/deck_generator/database_files"

      include RailsOverrides
      include DatabaseFiles

      source_root File.expand_path("../templates", __FILE__)

      # All but the first aliases should be considered deprecated
      class_option "monkey",
                   type: :boolean, aliases: %w[-M --mod-dev], default: false, group: :runtime,
                   desc: "Prepare deck for monkey (mod developer)"

      class_option "platypus",
                   type: :boolean, aliases: %w[-P --core-dev -c], default: false,
                   desc: "Prepare deck for platypus (core development)", group: :runtime

      class_option "repo-path",
                   type: :string, aliases: %w[-R -g --gem-path], default: "", group: :runtime,
                   desc: "Path to local decko repository " \
                         "(Default, use env DECKO_REPO_PATH)"

      class_option :database,
                   type: :string, aliases: %w[-D -d], default: "mysql",
                   desc: "Preconfigure for selected database " \
                         "(options: #{DATABASES.join('/')})"

      class_option "interactive",
                   type: :boolean, aliases: %w[-I -i], default: false, group: :runtime,
                   desc: "Prompt with dynamic installation options"

      public_task :set_default_accessors!
      public_task :create_root

      def self.banner
        "decko new #{arguments.map(&:usage).join(' ')} [options]"
      end

      ## should probably eventually use rails-like AppBuilder approach,
      # but this is a first step.
      def dev_setup
        determine_repo_path
        @include_jasmine_engine = false
        if platypus?
          platypus_setup
        elsif monkey?
          monkey_setup
        end
      end

      def rakefile
        template "Rakefile.erb", "Rakefile"
      end

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
        template "Gemfile.erb", "Gemfile"
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
          template "application.erb", "application.rb"
          template "routes.erb", "routes.rb"
          template "environment.erb", "environment.rb"
          template "boot.erb", "boot.rb"
          template "databases/#{options[:database]}.yml", "database.yml"
          template "cucumber.yml" if platypus?
          template "initializers/cypress_on_rails.rb" if platypus?
          template "puma.rb"
        end
        template "rspec", ".rspec"
        template "simplecov", ".simplecov"
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
          Interactive.new(destination_root, (monkey? || platypus?)).run
        else
          puts "Now:
    1. Run `cd #{File.basename(destination_root)}` to move your new deck directory
    2. Run `decko seed` to seed your database (see db configuration in config/database.yml).
    3. Run `decko server` to start your server"
        end
      end

      def repo_path_constraint
        @repo_path.present? ? %(, path: "#{@repo_path}") : ""
      end

      def javascript_spec_setup
        empty_directory "spec/javascripts/support"
        jasmine_prefix = platypus? ? "decko" : "deck"
        inside "spec/javascripts/support" do
          template "#{jasmine_prefix}_jasmine.yml", "jasmine.yml"
        end
      end

      protected

      def shark?
        !(monkey? || platypus?)
      end

      def monkey?
        options[:monkey]
      end

      def platypus?
        options[:platypus]
      end

      def determine_repo_path
        env_repo_path = ENV["DECKO_REPO_PATH"]
        @repo_path = env_repo_path.present? ? env_repo_path.to_s : options["repo-path"]
      end

      def platypus_setup
        prompt_for_repo_path

        @spec_path = @repo_path
        @spec_helper_path = File.join @spec_path, "card", "spec", "spec_helper"

        # ending slash is important in order to load support and step folders
        @features_path = File.join @repo_path, "decko/features/"
        @simplecov_config = "card_core_dev_simplecov_filters"
        shared_dev_setup
      end

      def prompt_for_repo_path
        return if @repo_path.present?
        @repo_path = ask "Enter the path to your local decko repository: "
      end

      def monkey_setup
        @spec_path = "mod/"
        @spec_helper_path = "./spec/spec_helper"
        @simplecov_config = "card_simplecov_filters"
        shared_dev_setup
        inside("spec") { template "spec_helper.rb" }
      end

      def shared_dev_setup
        @cardio_gem_root = File.join @repo_path, "card"
        @decko_gem_root = File.join @repo_path, "decko"
        @include_jasmine_engine = true
        empty_directory "bin"
        inside "bin" do
          template "spring"
        end
      end
    end
  end
end
