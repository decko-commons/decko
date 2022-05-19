// bar_and_box.js.coffee
(function() {
  $(window).ready(function() {
    $("body").on("click", ".bar-menu", function(e) {
      return e.stopImmediatePropagation();
    });
    $(document).on('click', "._card-link", function() {
      return window.location = decko.path($(this).data("cardLinkName"));
    });
    $("body").on("click", "._click-select-editor ._select-item", function(event) {
      var selectEditor;
      selectEditor = $(this).closest("._click-select-editor");
      selectEditor.find(".selected").removeClass("selected");
      $(this).closest("._select-item").addClass("selected");
      return event.stopPropagation();
    });
    $("body").on("click", "._click-multiselect-editor ._select-item", function(event) {
      $(this).closest("._select-item").toggleClass("selected");
      return event.stopPropagation();
    });
    return $('body').on('click', "._card-link a", function(event) {
      if ($(this).hasClass("over-card-link")) {
        return event.stopPropagation();
      } else {
        return event.preventDefault();
      }
    });
  });

}).call(this);
