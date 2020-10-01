module Decko
  module Generators
    class DeckGenerator
      module DatabaseFiles
        protected

        def database_gemfile_entry
          return [] if options[:skip_active_record]
          gem_name, gem_version = gem_for_database
          msg = "Use #{options[:database]} as the database for Active Record"
          GemfileEntry.version gem_name, gem_version, msg
        end

        def database_gem_and_version
          entry = database_gemfile_entry
          text = %('#{entry.name}')
          text << %(, '#{entry.version}') if entry.version
          # single quotes to prevent, eg: `gem "pg", ">= 0.18', '< 2.0"`
          text
        end

        def mysql_socket
          return if RbConfig::CONFIG["host_os"] =~ /mswin|mingw/

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
