require "cardio/migration"

module Cardio
  class Migration
    class Schema < Migration
      @migration_type = :schema
    end
  end
end
