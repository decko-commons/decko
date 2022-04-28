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
  CardSpecLoader.rspec_config
end

CardSpecLoader.helper

Decko::ModsSpecHelper = :needs_a_value_so_spring_loader_is_happy
