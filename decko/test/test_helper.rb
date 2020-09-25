# -*- encoding : utf-8 -*-
ENV["RAILS_ENV"] = "test"
require File.expand_path("../../lib/decko/environment", __FILE__)
require "rails/test_help"
require "pathname"

unless defined? TEST_ROOT
  TEST_ROOT = Pathname.new(File.expand_path(File.dirname(__FILE__))).cleanpath(true).to_s

  class ActiveSupport::TestCase
    # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
    #
    # Note: You'll currently still have to declare fixtures explicitly in integration tests
    # -- they do not yet inherit this setting
    # fixtures :all

    # Add more helper methods to be used by all tests here...

    # Transactional fixtures accelerate your tests by wrapping each test method
    # in a transaction that's rolled back on completion.  This ensures that the
    # test database remains unchanged so your fixtures don't have to be reloaded
    # between every test method.  Fewer database queries means faster tests.
    #
    # Read Mike Clark's excellent walkthrough at
    #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
    #
    # Every Active Record database supports transactions except MyISAM tables
    # in MySQL.  Turn off transactional fixtures in this case; however, if you
    # don't care one way or the other, switching from MyISAM to InnoDB tables
    # is recommended.
    self.use_transactional_fixtures = true

    # Instantiated fixtures are slow, but give you @david where otherwise you
    # would need people(:david).  If you don't want to migrate your existing
    # test cases which use the @david style and don't mind the speed hit (each
    # instantiated fixtures translates to a database query per test method),
    # then set this back to true.
    self.use_instantiated_fixtures  = false

    def prepare_url url, cardtype
      if url =~ /:id/
        # find by naming convention in test data:
        renames = { "layout_type" => "Layout", "search_type" => "Search" }
        if card = Card["Sample #{renames[cardtype] || cardtype}"]
          url.gsub!(/:id/, "~#{card.id}")
        else
          puts("ERROR finding 'Sample #{cardtype}'")
        end
      end
      url
    end
  end
end
