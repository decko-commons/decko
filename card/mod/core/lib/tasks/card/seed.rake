namespace :card do
  namespace :seed do
    desc "reseed, migrate, re-clean, and re-dump"
    task update: :environment do
      ENV["STAMP_MIGRATIONS"] = "true"
      ENV["UPDATE_SEED"] = "true"
      # tells Cardio::Seed to use fixtures upon which the seeds being updated depend

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
      Cardio::Seed.clean
      Card.empty_trash
      Card::Cache.reset_all
    end

    desc "dump db to bootstrap fixtures"
    task dump: :environment do
      Card::Cache.reset_all
      Cardio::Seed.dump
    end
  end
end
