require "rails"
require "cardio"
require "cardio/mod"

%w[
  active_record/railtie
  active_storage/engine
  action_view/railtie
  action_mailer/railtie
  active_job/railtie
  action_mailbox/engine
  rails/test_unit/railtie
  sprockets/railtie
  cardio/railtie
].each do |railtie|
  require railtie
end
