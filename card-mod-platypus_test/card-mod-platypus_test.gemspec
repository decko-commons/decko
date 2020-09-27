# -*- encoding : utf-8 -*-

require "../decko_gem"

DeckoGem.mod "platypus_test" do |s, _d|
  s.summary = "testing support for core developers (platypuses)"
  s.description = ""
  [
    ["card-mod-monkey_test"],
    ["fog-aws"],
    ["rails-controller-testing"],
    ["rspec-html-matchers", "0.9.1"],
    ["rr"],
    ["simplecov", "~> 0.7.1"], # test coverage
    ["codeclimate-test-reporter"],

    # ["guard-rspec", "~> 4.2"             # trigger test runs based on file edits,
    # currently not compatible with spring-watcher-listen

    # CUKES see features dir
    ["cucumber-rails", "~> 1.8.0"], # feature-driven-development suite
    ["capybara", "~> 3.12"],
    ["selenium-webdriver", "3.141.0"],
    ["chromedriver-helper", "~> 2.1.0"],
    # gem 'capybara-webkit'
    ["launchy"], # lets cucumber launch browser windows

    ["timecop", "=0.3.5"], # not clear on use/need.
    #                                        referred to in shared_data.rb
    # NOTE: had weird errors with timecop 0.4.4.  would like to update when possible

    ["email_spec"], #
    ["database_cleaner", "~> 1.5"], # used by cucumber for db transactions

    ["minitest"],

    ["i18n-tasks", "~> 0.9.5"]  # See if I18n keys are missing or unused
  ].each do |dep|
    s.add_runtime_dependency(*dep)
  end
end
