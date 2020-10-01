require 'active_record'

module Cardio
  class Cardio::ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end

class Card < Cardio::ApplicationRecord
end

ActiveSupport.run_load_hooks(:after_application_record, self)
