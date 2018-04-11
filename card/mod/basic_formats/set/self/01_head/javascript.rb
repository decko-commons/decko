format :html do
  # add tuples containing a
  #  - the codename of a card with javascript config (usually in json format)
  #  - the name of a javascript method that handles the config
  basket :mod_js_config

  def ie9
    ie9_card = Card[:script_html5shiv_printshiv]
    "<!--[if lt IE 9]>"\
    "#{javascript_include_tag ie9_card.machine_output_url if ie9_card}"\
    "<![endif]-->"
  end

  def decko_variables
    vars = {
      "window.decko": ["{rootPath:'%<root>s'", { root: Card.config.relative_url_root }],
      "decko.doubleClick": Card.config.double_click,
      "decko.cssPath":

      ""
    }
    varvals = ["window.decko={rootPath:'#{Card.config.relative_url_root}'}"]
    card.have_recaptcha_keys? &&
      varvals << "decko.recaptchaKey='#{Card.config.recaptcha_public_key}'"
    (c = Card[:double_click]) && !Card.toggle(c.content) &&
      varvals << "decko.noDoubleClick=true"
    @css_path &&
      varvals << "decko.cssPath='#{@css_path}'"
    javascript_tag { varvals * ";" }
  end

  def configure_double_click vars
    case Card.config.double_click
      when :off   then vars["decko.doubleClick"] = true
      when
    end
     if Card.config.double_click
  end

  def trigger_slot_ready
    <<-HTML
      <script type="text/javascript">
        $('document').ready(function() {
          $('.card-slot').trigger('slotReady');
        })
      </script>
    HTML
  end


  def google_analytics_head_javascript
    return unless (ga_key = Card.global_setting(:google_analytics_key))
    <<-HTML
      <script type="text/javascript">
        var _gaq = _gaq || [];
        _gaq.push(['_setAccount', '#{ga_key}']);
        _gaq.push(['_setPageGroup', '1', '#{root.card.type_name}']);
        _gaq.push(['_trackPageview']);
        (function() {
          var ga = document.createElement('script');
          ga.type = 'text/javascript';
          ga.async = true;
          ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
          var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
        })();
      </script>
    HTML
  end

  def google_analytics
    return unless (ga_key = Card.global_setting(:google_analytics_key))
    <<-HTML
      <script type="text/javascript">
        var _gaq = _gaq || [];
        _gaq.push(['_setAccount', '#{ga_key}']);
        _gaq.push(['_trackPageview']);
        (function() {
          var ga = document.createElement('script');
          ga.type = 'text/javascript';
          ga.async = true;
          ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
          var s = document.getElementsByTagName('script')[0];
          s.parentNode.insertBefore(ga, s);
        })();
      </script>
    HTML
  end




  def mod_configs
    mod_js_config.map do |codename, js_decko_function|
      config_json = escape_javascript Card.global_setting(codename)
      javascript_tag { "decko.#{js_decko_function}('#{config_json}')" }
    end
  end

  def recaptcha
    javascript_include_tag "https://www.google.com/recaptcha/api.js", async: "", defer: ""
  end
end
