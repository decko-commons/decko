# -*- encoding : utf-8 -*-

class Require01Migrations < Cardio::Migration::Schema
  def self.up
    raise %(
Your database is not ready to be migrated to #{Cardio::Version.release}.
Please first install Decko version 0.1 and run `rake db:migrate`.
)
  end

  def self.down
    raise "Older migrations have been removed because of incompatibility."
  end
end
