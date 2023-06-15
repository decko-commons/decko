# -*- encoding : utf-8 -*-

module Cardio
  module Generators
    # adds Cardio::Generators::ClassMethods to standard rails generator base class.
    class Base < ::Rails::Generators::Base
      extend ClassMethods
    end
  end
end
