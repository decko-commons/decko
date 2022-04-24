require "decko/application"
require_relative "alias"

CARD_TASKS =
  [
    { assets: %i[refresh code wipe] },
    :eat,
    :migrate,
    { migrate: %i[cards structure core_cards deck_cards redo stamp] },
    { mod: %i[list symlink missing uninstall install] },
    :reset_cache,
    :seed,
    { seed: %i[clean dump replant update] },
    :setup,
    :sow,
    :update
  ].freeze

link_task CARD_TASKS, from: :decko, to: :card

decko_namespace = namespace :decko do
  desc "empty the card tables"
  task :clear do
    conn = ActiveRecord::Base.connection

    puts "delete all data in bootstrap tables"
    Cardio::Seed::TABLES.each do |table|
      conn.delete "delete from #{table}"
    end
  end

  desc "reset with an empty tmp directory"
  task :reset_tmp do
    tmp_dir = Decko.paths["tmp"].first
    if Decko.paths["tmp"].existent
      Dir.foreach(tmp_dir) do |filename|
        next if filename.starts_with? "."

        FileUtils.rm_rf File.join(tmp_dir, filename), secure: true
      end
    else
      Dir.mkdir tmp_dir
    end
  end

  desc "insert existing card migrations into schema_migrations_cards " \
       "to avoid re-migrating"
  task :assume_card_migrations do
    require "decko/engine"
    Cardio::Schema.assume_migrated_upto_version :core_cards
  end

end

def failing_loudly task
  yield
rescue StandardError
  # TODO: fix this so that message appears *after* the errors.
  # Solution should ensure that rake still exits with error code 1!
  raise "\n>>>>>> FAILURE! #{task} did not complete successfully." \
        "\n>>>>>> Please address errors and re-run:\n\n\n"
end

def version
  ENV["VERSION"] ? ENV["VERSION"].to_i : nil
end
