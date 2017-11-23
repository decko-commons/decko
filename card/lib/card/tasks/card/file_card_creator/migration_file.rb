class Card
  class FileCardCreator
    module MigrationFile
      def create_migration_file
        puts "creating migration file...".yellow
        migration_out = `bundle exec decko generate card:migration #{@name}`
        migration_file = migration_out[/db.*/]
        write_at migration_file, 5, migration_content # 5 is line no.
      end

      def migration_content
        <<-RUBY
    add_#{@category} "#{@name}",
                type_id: #{type_id},
                to: "#{rule_card_name}"
        RUBY
      end
    end
  end
end