require "cardio/seed"

namespace :decko do
  namespace :seed do
    desc "reseed, migrate, re-clean, and re-dump"
    task update: :environment do
      ENV["STAMP_MIGRATIONS"] = "true"
      ENV["GENERATE_FIXTURES"] = "true"
      %w[reseed seed:clean eat update seed:supplement assets:code seed:dump]
        .each do |task|
        puts "invoking: #{task}".green
        Rake::Task["decko:#{task}"].invoke
        puts "yeti asset input: #{'yeti skin+*asset input'.card_id}".red
      end
    end

    desc "remove unneeded cards, acts, actions, changes, and references"
    task clean: :environment do
      Card::Act.update_all actor_id: Card::WagnBotID
      delete_ignored_cards
      clean_history
      clean_time_and_user_stamps
      clean_assets
      Card.empty_trash
      Card::Cache.reset_all
    end

    # TODO: delete this
    task debug_asset_input: :environment  do
      puts "yeti asset input: #{'yeti skin+*asset input'.card_id}".red
      clean_assets
      puts "yeti asset input: #{'yeti skin+*asset input'.card_id}".red
      Rake::Task["card:mod:install"].invoke
      puts "yeti asset input: #{'yeti skin+*asset input'.card_id}".red
    end

    task clean_assets: :environment do
      clean_assets
    end

    def clean_unwantved_cards
      Card.search(right: { codename: "all" }).each(&:delete!)
    end

    # TODO: obviate this
    def delete_ignored_cards
      return unless (ignore = Card["*ignore"])

      Card::Auth.as_bot do
        puts "deleting ignored items: #{ignore.item_names.join ', '}"
        ignore.item_cards.each(&:delete!)
      end
    end

    # TODO: obviate this
    def clean_assets
      puts "delete asset inputs"
      Card::Auth.as_bot do
        Card.where(right_id: :asset_input.card_id).delete_all
      end
      Card::Cache.reset_all
    end

    def clean_history
      puts "clean history"
      act = Card::Act.create! actor_id: Card::WagnBotID, card_id: Card::WagnBotID
      Card::Action.make_current_state_the_initial_state act
      # conn.execute("truncate card_acts")
      ActiveRecord::Base.connection.execute("truncate sessions")
    end

    def clean_time_and_user_stamps
      puts "clean time and user stamps"
      conn = ActiveRecord::Base.connection
      who_and_when = [Card::WagnBotID, Time.now.utc.to_s(:db)]
      conn.update "UPDATE cards SET " \
                  "creator_id=%1$s, created_at='%2$s', " \
                  "updater_id=%1$s, updated_at='%2$s'" % who_and_when
      conn.update "UPDATE card_acts SET actor_id=%s, acted_at='%s'" % who_and_when
    end

    desc "add test data"
    task supplement: :environment do
      add_test_data
    end

    def add_test_data
      return unless Rails.env == "test"

      load Cardio::Seed.test_script_path
      SharedData.add_test_data
    end

    desc "dump db to bootstrap fixtures"
    task dump: :environment do
      Card::Cache.reset_all
      Cardio::Seed::TABLES.each do |table|
        i = "000"
        write_seed_file table do
          yamlize_records table do |record, hash|
            hash["#{table}_#{i.succ!}"] = record
          end
        end
      end
    end

    def write_seed_file table
      path = Rails.env == "test" ? Cardio::Seed.test_path : Cardio::Seed.path
      filename = File.join path, "#{table}.yml"
      File.open filename, "w" do |file|
        file.write yield
      end
    end

    def yamlize_records table
      data = ActiveRecord::Base.connection.select_all "select * from #{table}"
      YAML.dump(
        data.each_with_object({}) do |record, hash|
          record["trash"] = false if record.key? "trash"
          record["draft"] = false if record.key? "draft"
          yield record, hash
        end
      )
    end
  end
end
