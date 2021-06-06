# -*- encoding : utf-8 -*-

module Cardio
  module Generators
    # adds Cardio::Generators::ClassMethods to standard rails generator base class.
    class Base < ::ActiveRecord::Generators::Base
      extend ClassMethods
    end
  end
end
