# This file specifies the default gem set used in semaphore. It is here to encourage
# frequent updates

source "http://rubygems.org"

path "./" do
  gem "card", require: false
  gem "decko"
end

gem "mysql2"
gem "thin"

path "./mod" do
  gem "card-mod-defaults"
  gem "card-mod-delayed_job"
  gem "card-mod-monkey", group: :development
end

path "./support" do
  gem "decko-cucumber", group: :test
  gem "decko-cypress", group: %i[cypress test]
  gem "decko-profile", group: :profile
  gem "decko-rspec", group: :test
  gem "decko-spring", group: %i[test development]
end

# PLATYPUSES
# This mod is strongly recommended for platypuses – coders working on the decko core
gem "card-mod-platypus", group: :test, path: "./mod"

# The following allows simple (non-gem) mods to specify gems via a Gemfile.
# You may need to alter this code if you move such mods to an unconventional location.
# Dir.glob("mod/**/Gemfile").each { |gemfile| instance_eval File.read(gemfile) }
gem "rack-test", "!=2.0.0"