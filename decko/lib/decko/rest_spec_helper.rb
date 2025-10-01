# -*- encoding : utf-8 -*-

module Decko
  # for use in REST API specs
  module RestSpecMethods
    def with_api_key_for usermark
      key_card = Card.fetch [usermark, :account, :api_key], new: {}
      key_card.content = "asdkfjh1023498203jdfs"
      Card::Auth.as_bot { key_card.save! }
      yield key_card.content
    end
  end

  # for use in REST API specs
  module RestSpecHelper
    def self.describe_api &block
      RSpec.describe CardController, type: :controller do
        routes { Decko::Engine.routes }
        include Capybara::DSL
        include RestSpecMethods

        instance_eval(&block)
      end
    end
  end
end
