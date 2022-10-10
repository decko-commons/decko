// bar_and_box.js.coffee
(function() {
  $(window).ready(function() {
    return $(document).on('click', "._card-link", function() {
      var cl;
      cl = $(this);
      if (cl.data("skip") === "on") {
        return cl.data("skip", null);
      } else if (cl.closest("._card-link-modal")[0]) {
        return cl.find("._modal-page-link").trigger("click");
      } else {
        return window.location = decko.path(cl.data("cardLinkName"));
      }
    });
  });

  decko.slot.ready(function(slot) {
    return slot.find("._card-link a, ._card-link ._card-link-clickable").on("click", function(event) {
      var a;
      a = $(this);
      if (a.hasClass("_over-card-link") || a.closest("._over-card-link")[0]) {
        return a.closest("._card-link").data("skip", "on");
      } else {
        return event.preventDefault();
      }
    });
  });

}).call(this);

// click_select.js.coffee
(function() {
  $("body").on("click", "._click-multiselect-editor ._select-item", function(event) {
    $(this).closest("._select-item").toggleClass("selected");
    return event.stopPropagation();
  });

  $("body").on("click", "._click-select-editor ._select-item", function(event) {
    var selectEditor;
    selectEditor = $(this).closest("._click-select-editor");
    selectEditor.find(".selected").removeClass("selected");
    $(this).closest("._select-item").addClass("selected");
    return event.stopPropagation();
  });

}).call(this);
