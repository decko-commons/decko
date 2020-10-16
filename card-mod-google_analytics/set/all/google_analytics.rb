require "staccato"

mattr_accessor :server_side_tracking_formats

self.server_side_tracking_formats = %i[csv json]

event :track_page, before: :show_page, when: :track_page? do
  tracker.pageview path: Env.controller.request&.path, host: Env.host, title: name
end

def track_page?
  google_analytics_key &&
    Env.controller&.response_format&.in?(server_side_tracking_formats)
end

def tracker
  return unless google_analytics_key

  ::Staccato.tracker google_analytics_key # , nil, ssl: true
end

def google_analytics_key
  @google_analytics_key ||=
    Card::Rule.global_setting(:google_analytics_key) ||
    Card.config.google_analytics_key
end

format :html do
  delegate :tracker, :google_analytics_key, to: :card

  def views_in_head
    super << :google_analytics_snippet
  end

  view :google_analytics_snippet, unknown: true, perms: :none do
    haml :google_analytics_snippet if google_analytics_key
  end

  def google_analytics_snippet_vars
    { anonymizeIP: true }
  end
end
