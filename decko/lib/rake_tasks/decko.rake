require "decko/application"
require_relative "alias"

CARD_TASKS = (
  %i[eat migrate reset_cache reset_tmp seed setup sow update] +
  [{ assets: %i[refresh code wipe] },
   { migrate: %i[cards structure core_cards deck_cards redo stamp] },
   { mod: %i[list symlink missing uninstall install] },
   { seed: %i[build clean dump plow polish replant update] }]
).freeze

link_task CARD_TASKS, from: :decko, to: :card
