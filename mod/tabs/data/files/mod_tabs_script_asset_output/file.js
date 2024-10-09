// tab.js.coffee
(function() {
  $(window).ready(function() {
    return $('body').on('show.bs.tab', 'a.load[data-bs-toggle="tab"][data-url]', function(e) {
      var tab_content, tab_id, tabname, targ, url;
      targ = $(e.target);
      tab_id = targ.attr("href");
      url = targ.data("url");
      tabname = $(this).data("tabName");
      targ.removeClass("load");
      tab_content = $(tab_id);
      return $.ajax({
        url: url,
        success: function(html) {
          tab_content.append(html);
          window.history.pushState("tab", "", "?tab=" + tabname);
          return decko.contentLoaded(tab_content, $(this));
        }
      });
    });
  });

}).call(this);
