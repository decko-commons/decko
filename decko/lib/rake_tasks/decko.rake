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
    :reset_tmp,
    :seed,
    { seed: %i[clean dump replant update] },
    :setup,
    :sow,
    :update
  ].freeze

link_task CARD_TASKS, from: :decko, to: :card

namespace :decko do
  # desc "empty the card tables"
  # task :clear do
  #   conn = ActiveRecord::Base.connection
  #
  #   puts "delete all data in bootstrap tables"
  #   Cardio::Seed::TABLES.each do |table|
  #     conn.delete "delete from #{table}"
  #   end
  # end

  desc "insert existing card migrations into schema_migrations_cards " \
       "to avoid re-migrating"
  task :assume_card_migrations do
    require "decko/engine"
    Cardio::Schema.assume_migrated_upto_version :core_cards
  end
end

def version
  ENV["VERSION"] ? ENV["VERSION"].to_i : nil
end
