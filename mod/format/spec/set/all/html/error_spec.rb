RSpec.describe Card::Set::All::Html::Error do
  check_views_for_errors views: views(:html) - %i[debug_server_error server_error]
end
