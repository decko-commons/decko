# -*- encoding : utf-8 -*-

require "cardio" # only for card_gem_root
require File.join Cardio.gem_root, "spec/support/card_spec_loader.rb"
require "simplecov"

CardSpecLoader.init

CardSpecLoader.prefork do
  if defined?(Bundler)
    Bundler.require(:test)
    # if simplecov is activated in the Gemfile, it has to be required here
  end
  #  Cardio::Seed.test_path = File.dirname(__FILE__) + '/../fixtures'
  CardSpecLoader.rspec_config
end

CardSpecLoader.each_run do
  # This code will be run each time you run your specs.
end

CardSpecLoader.helper

Decko::ModsSpecHelper = :needs_a_value_so_spring_loader_is_happy
