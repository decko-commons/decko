require 'active_record'

ActiveSupport.run_load_hooks(:before_active_record, self)

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
