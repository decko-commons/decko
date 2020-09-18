# ARDEP: refactor this to a factory for configured storage modules that can store and use ActiveModel
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
