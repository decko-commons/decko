require 'active_record'

ActiveSupport.run_load_hooks(:before_application_record, self)

module Cardio
  class Cardio::ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end

ActiveSupport.run_load_hooks(:after_application_record, self)
