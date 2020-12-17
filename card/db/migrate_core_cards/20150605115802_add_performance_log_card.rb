# -*- encoding : utf-8 -*-

class AddPerformanceLogCard < Cardio::Migration::Core
  def up
    Card.create! name: "*performance log", type_code: :pointer, codename: :performance_log
  end
end
