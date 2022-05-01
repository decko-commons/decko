// bar_and_box.js.coffee
(function() {
  $(window).ready(function() {
    $("body").on("click", ".bar-menu", function(e) {
      return e.stopImmediatePropagation();
    });
    $(document).on('click', ".box, .bar", function() {
      return window.location = decko.path($(this).data("cardLinkName"));
    });
    return $('body').on('click', ".box a, .bar a", function(event) {
      debugger;
      if ($(this).hasClass("over-bar")) {
        return event.stopPropagation();
      } else {
        return event.preventDefault();
      }
    });
  });

}).call(this);
