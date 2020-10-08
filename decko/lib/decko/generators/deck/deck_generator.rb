require "rails/generators/app_base"

module Decko
  module Generators
    module Deck
      # Create new Decks (Decko Applications)
      class DeckGenerator < Rails::Generators::AppBase
        require "decko/generators/deck/deck_generator/rails_overrides"
        require "decko/generators/deck/deck_generator/deck_helper"

        include RailsOverrides
        include DeckHelper

        source_root File.expand_path("../templates", __FILE__)

        # All but the first aliases should be considered deprecated
        class_option "monkey",
                     type: :boolean, aliases: %w[-M --mod-dev],
                     default: false, group: :runtime,
                     desc: "Prepare deck for monkey (mod developer)"

        class_option "platypus",
                     type: :boolean, aliases: %w[-P --core-dev -c],
                     default: false, group: :runtime,
                     desc: "Prepare deck for platypus (core development)"

        class_option "repo-path",
                     type: :string, aliases: %w[-R -g --gem-path],
                     default: "", group: :runtime,
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

        # Generator works its way through each public method below

        def core_files
          erb_template "config.ru"
          erb_template "Gemfile"
          erb_template "Rakefile"
        end

        def empty_dirs
          %w[mod log files tmp].each { |dirname| empty_directory_with_keep_file dirname }
        end

        def dotfiles
          copy_file "pryrc", ".pryrc"
          copy_file "gitignore", ".gitignore"
          template "rspec.erb", ".rspec"
          template "simplecov.erb", ".simplecov"
        end

        def config
          inside "config" do
            erb_template "application.rb"
            erb_template "routes.rb"
            erb_template "environment.rb"
            erb_template "boot.rb"
            template "databases/#{options[:database]}.yml", "database.yml"
            template "cucumber.yml"
            template "initializers/cypress.rb" if platypus?
            template "puma.rb"
          end
        end

        def public
          inside "public" do
            template "robots.txt"
            inside("files") { template "htaccess", ".htaccess" }
          end
        end

        def spring
          inside("bin") { erb_template "spring" }
        end

        def script
          directory("script") { |content| "#{shebang}\n" + content }
          chmod "script", 0o755 & ~File.umask, verbose: false
        end

        def spec
          inside "spec" do
            if platypus?
              jasmine_yml :decko
            else
              jasmine_yml :deck
              template "spec_helper.rb"
            end
          end
        end

        public_task :run_bundle

        def seed_data
          if options["interactive"]
            Interactive.new(destination_root, (monkey? || platypus?)).run
          else
            puts "Now:
      1. Run `cd #{File.basename(destination_root)}` to enter your new deck directory
      2. Run `decko seed` to seed your database (see config/database.yml).
      3. Run `decko server` to start your server"
          end
        end

        protected

        def database_gemfile_entry
          return [] if options[:skip_active_record]
          gem_name, gem_version = gem_for_database
          msg = "Use #{options[:database]} as the database for Active Record"
          GemfileEntry.version gem_name, gem_version, msg
        end
      end
    end
  end
end
