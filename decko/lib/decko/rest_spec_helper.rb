# -*- encoding : utf-8 -*-

module Decko
  # For use in REST API specs
  module RestSpecHelper
    def self.describe_api &block
      RSpec.describe CardController, type: :controller do
        routes { Decko::Engine.routes }
        include Capybara::DSL
        instance_eval(&block)
      end
    end
  end
end
