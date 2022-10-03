namespace :card do
  namespace :seed do
    desc "completely regenerate seed fixtures starting with dependee seed fixtures"
    task build: [:plow, :polish, :dump]

    desc "regenerate seed fixtures quickly from current fixtures. " \
         "create and update only (no delete)"
    task update: [:replant, :polish, :dump]

    # desc "replant, polish, and dump seed. " \
    #      "Good when mods/assets have changed but pods haven't."
    # # note: this will not delete anything; it just eats new stuff.
    # task modify: %i[replant polish dump]

    desc "Truncates tables of each database for current environment and loads the seeds" \
         "(alias for db:seed:replant)"
    task replant: ["db:seed:replant"]

    desc "finalize seed data with migrations, installations, asset coding, and cleaning"
    task polish: :environment do
      ENV["STAMP_MIGRATIONS"] = "true"

      invoke_card_tasks %w[update assets:code]

      invoke_card_task "seed:clean" unless Rails.env.test?
      # It's important NOT to clean the test data and lose history, creator info, etc.
    end

    desc "reseed from the fixtures of the dependee seed mod"
    task plow: :environment do
      ENV["UPDATE_SEED"] = "true"
      # tells Cardio::Seed to use fixtures upon which the seeds being updated depend

      invoke_card_tasks %w[reset_tmp seed:replant]
    end

    desc "remove unneeded cards, acts, actions, changes, and references"
    task clean: :environment do
      Cardio::Seed.clean
      Cardio::Utils.empty_trash
      Card::Cache.reset_all
    end

    desc "dump db to bootstrap fixtures"
    task dump: :environment do
      Card::Cache.reset_all
      Cardio::Seed.dump
    end

    def invoke_card_tasks tasks
      tasks.each { |task| invoke_card_task task }
    end

    def invoke_card_task task
      puts "invoking: #{task}".green
      Rake::Task["card:#{task}"].invoke
    end
  end
end
