# -*- encoding : utf-8 -*-
# rubocop:disable Lint/AmbiguousRegexpLiteral, Lint/Syntax

require "uri"
require "cgi"
support_paths_file = File.join File.dirname(__FILE__), "..", "support", "paths"
require File.expand_path support_paths_file

Given /^Jobs are dispatched$/ do
  Delayed::Worker.new.work_off
end

Given /^site simulates setup need$/ do
  Card::Auth.simulate_setup_need!
end

Given /^site stops simulating setup need$/ do
  Card::Auth.simulate_setup_need! false
  step "I am signed out"
end
