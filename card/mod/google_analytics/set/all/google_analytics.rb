
format :html do
  def views_in_head
    super << :google_analytics_snippet
  end

  view :google_analytics_snippet, tags: :unknown_ok do
    return unless google_analytics_key
    javascript_tag { google_analytics_snippet_javascript }
  end

  def google_analytics_key
    @google_analytics_key ||= Card.global_setting :google_analytics_key
  end

  def google_analytics_snippet_vars
    [[:_setAccount, google_analytics_key],
     [:_trackPageview]]
  end

  def google_analytics_snippet_vars_string
    google_analytics_snippet_vars.map do |array|
      "_gaq.push([#{array.map { |i| "'#{i}'" }.join ', '}]);"
    end.join " "
  end

  def google_analytics_snippet_javascript
    <<-JAVASCRIPT
      var _gaq = _gaq || []; #{google_analytics_snippet_vars_string}
      (function() {
        var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
        ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
        var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
      })();
    JAVASCRIPT
  end
end
