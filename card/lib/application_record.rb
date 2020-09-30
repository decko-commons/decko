require 'active_record'

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end

ActiveSupport.run_load_hooks(:after_active_record, self)
