
format :html do
  def views_in_head
    super << :google_analytics_snippet
  end

  view :google_analytics_snippet, unknown: true, perms: :none do
    haml :google_analytics_snippet if google_analytics_key
  end

  def google_analytics_key
    @google_analytics_key ||= Card::Rule.global_setting :google_analytics_key
  end

  def google_analytics_snippet_vars
    { anonymizeIP: true }
  end
end
