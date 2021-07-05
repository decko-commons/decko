require "staccato"

event :track_page, before: :show_page, when: :track_page_from_server? do
  tracker.pageview tracker_options
end

def google_analytics_key
  @google_analytics_key ||=
    Card::Rule.global_setting(:google_analytics_key) ||
    Card.config.google_analytics_key
end

def tracker
  tracker_key && ::Staccato.tracker(tracker_key) # , nil, ssl: true
end

# can override to have separate keys for web and API
def tracker_key
  @tracker_key ||= google_analytics_key
end

def tracker_options
  r = Env.controller.request
  {
    path: r.path,
    host: Env.host,
    title: name,
    uid: Auth.current_id,
    uip: r.remote_ip,
    ni: 1, # non-interactive
  }
end

# for override
def track_page_from_server?
  false
end

format :html do
  delegate :google_analytics_key, to: :card

  def views_in_head
    super << :google_analytics_snippet
  end

  view :google_analytics_snippet, unknown: true, perms: :none do
    haml :google_analytics_snippet if google_analytics_key
  end

  def google_analytics_snippet_vars
    { anonymizeIp: true }
  end
end
