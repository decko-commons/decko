module Decko
  module Generators
    module Deck
      class DeckGenerator
        # Protected helper methods for DeckGenerator.
        # Many methods are called from .erb files.
        module DeckHelper
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

          def erb_template name
            template "#{name}.erb", name
          end

          def repo_path
            @repo_path ||= determine_repo_path
          end

          def determine_repo_path
            @repo_path_determined ? (return nil) : (@repo_path_determined = true)
            path = options["repo-path"]
            path = ENV["DECKO_REPO_PATH"] if path.blank?
            path = prompt_for_repo_path if path.blank? && platypus?
            path.to_s
          end

          def repo_path_constraint
            repo_path.present? ? %(, path: "#{repo_path}") : ""
          end

          def prompt_for_repo_path
            @repo_path = ask "Enter the path to your local decko repository: "
          end

          def spec_path
            @spec_path ||= platypus? ? repo_path : "mod/"
          end

          def spec_helper_path
            @spec_helper_path ||=
              platypus? ? "#{repo_path}/card/spec/spec_helper" : "./spec/spec_helper"
          end

          def features_path
            @features_path ||=
              platypus? ? File.expand_path("#{repo_path}/decko/features/") : "mod/"
          end

          # FIXME: these gem roots are not correct unless repo_path is specified
          def cardio_gem_root
            @cardio_gem_root ||= File.join repo_path, "card"
          end

          def decko_gem_root
            @decko_gem_root ||= File.join repo_path, "decko"
          end

          def database_gem_and_version
            entry = database_gemfile_entry
            text = %('#{entry.name}')
            text << %(, '#{entry.version}') if entry.version
            # single quotes to prevent, eg: `gem "pg", ">= 0.18', '< 2.0"`
            text
          end

          def simplecov_config
            "" # TODO: add simplecov configs here
          end

          def jasmine_yml prefix
            inside("javascripts/support") do
              template "#{prefix}_jasmine.yml.erb", "jasmine.yml"
            end
          end

          def mysql_socket
            return if RbConfig::CONFIG["host_os"].match?(/mswin|mingw/)

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
            ].find { |f| File.exist?(f) }
          end
        end
      end
    end
  end
end
