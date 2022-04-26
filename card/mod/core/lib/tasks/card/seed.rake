namespace :card do
  namespace :seed do
    desc "reseed, migrate, re-clean, and re-dump"
    task update: :environment do
      ENV["STAMP_MIGRATIONS"] = "true"
      ENV["UPDATE_SEED"] = "true"

      tasks = %w[reset_tmp seed:replant eat]
      # important not to clean test data and lose history, creator info, etc.
      tasks += %w[update assets:code seed:clean] unless Rails.env.test?
      tasks << "seed:dump"

      Card::Cache.reset_all
      tasks.each do |task|
        puts "invoking: #{task}".green
        Rake::Task["card:#{task}"].invoke
      end
    end

    desc "Truncates tables of each database for current environment and loads the seeds" \
         "(alias for db:seed:replant)"
    task replant: ["db:seed:replant"]

    desc "remove unneeded cards, acts, actions, changes, and references"
    task clean: :environment do
      Card::Act.update_all actor_id: Card::WagnBotID
      clean_history
      clean_time_and_user_stamps
      Card.empty_trash
      Card::Cache.reset_all
    end

    def clean_history
      puts "clean history"
      act = Card::Act.create! actor_id: Card::WagnBotID, card_id: Card::WagnBotID
      Card::Action.make_current_state_the_initial_state act
      Card::Act.where("id <> #{act.id}").delete_all
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

    desc "dump db to bootstrap fixtures"
    task dump: :environment do
      Card::Cache.reset_all
      Cardio::Seed.dump
    end
  end
end
