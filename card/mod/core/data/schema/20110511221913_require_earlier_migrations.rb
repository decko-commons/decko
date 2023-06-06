# -*- encoding : utf-8 -*-

class RequireEarlierMigrations < Cardio::Migration::Schema
  def up
    raise %(
Your database is not ready to be migrated to #{Cardio::Version.release}.
You will need to do incremental upgrades.
Please first install version 1.6.1 and run `rake db:migrate`.
Then install version 1.8.0 and run `rake db:migrate`.

Sorry about this! We're working to minimize these hassles in the future.
)
  end

  def down
    raise "Older migrations have been removed because of incompatibility."
  end
end
