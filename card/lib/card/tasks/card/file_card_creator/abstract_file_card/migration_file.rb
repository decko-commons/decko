class Card
  class FileCardCreator
    class AbstractFileCard
      # Module that provides #create_migration_file method for classes that
      # inherit from AbstractFileCard.
      # It uses the decko generator to create the migration.
      module MigrationFile
        def create_migration_file
          puts "creating migration file...".yellow
          migration_out = `#{migrate_command}`
          return if migration_out.include?("conflict")

          migration_file_name = migration_out[/db.*/]
          write_at migration_file_name, 5, indented_migration_content # 5 is line no.
        end

        private

        def migrate_command
          cmd = "bundle exec decko generate card:migration add_#{@codename}"
          cmd += " --force" if @force
          cmd
        end

        def indented_migration_content
          migration_file_content.lines.map do |line|
            " " * 4 + line
          end.join
        end

        def migration_file_content
          indent = " " * category.to_s.size
          <<-RUBY.strip_heredoc
            add_#{category} "#{remove_prefix @name}",
                #{indent} type_id: #{type_id},
                #{indent} to: "#{rule_card_name}"
          RUBY
        end

        def remove_prefix name
          name.sub(/^(?:#{category}):?_?\s*/, "")
        end

        def type_id
          "Card::#{type_codename.to_s.camelcase}ID"
        end
      end
    end
  end
end
