# -*- encoding : utf-8 -*-

class Require18Migrations < ActiveRecord::Migration[4.2]
  def self.up
    raise %(
Your database is not ready to be migrated to #{Cardio::Version.release}.
Please first install version 1.8.0 and run `rake db:migrate`.

Sorry about this! We're working to minimize these hassles in the future.
)
  end

  def self.down
    raise "Older migrations have been removed because of incompatibility."
  end
end
