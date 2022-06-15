Cardio::Railtie.config.tap do |config|
  config.closed_search_limit = 10
  config.paging_limit = 20
  config.search_box_match_start_only = true
end
