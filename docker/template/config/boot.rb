# -*- encoding : utf-8 -*-

require 'rubygems'

# defaults to development mode without the following
ENV['RAILS_ENV'] ||= 'production'

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path("Gemfile")

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])
