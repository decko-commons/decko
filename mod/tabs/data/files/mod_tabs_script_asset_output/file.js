// tab.js.coffee
(function() {
  $(window).ready(function() {
    return $('body').on('show.bs.tab', 'a.load[data-bs-toggle="tab"][data-url]', function(e) {
      var tab_id, url;
      tab_id = $(e.target).attr('href');
      url = $(e.target).data('url');
      $(e.target).removeClass('load');
      return $.ajax({
        url: url,
        success: function(html) {
          $(tab_id).append(html);
          return decko.contentLoaded($(tab_id), $(this));
        }
      });
    });
  });

}).call(this);
