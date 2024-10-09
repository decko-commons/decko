// bar_and_box.js.coffee
(function() {
  var cardLinkPath, openInNewTab;

  $(window).ready(function() {
    return $(document).on('click', "._card-link", function(event) {
      var cl;
      cl = $(this);
      if (cl.data("skip") === "on") {
        return cl.data("skip", null);
      } else if (openInNewTab(event)) {
        return window.open(cardLinkPath(cl), "_tab_" + Math.floor(Math.random() * 1000));
      } else if (cl.closest("._card-link-modal")[0]) {
        return cl.find("._modal-page-link").trigger("click");
      } else {
        return window.location = cardLinkPath(cl);
      }
    });
  });

  openInNewTab = function(event) {
    return event.metaKey;
  };

  cardLinkPath = function(cl) {
    return decko.path(cl.data("cardLinkUrl") || cl.data("cardLinkName"));
  };

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
  $(window).ready(function() {
    $("body").on("click", "._click-multiselect-editor ._select-item", function(event) {
      $(this).closest("._select-item").toggleClass("selected");
      return event.stopPropagation();
    });
    return $("body").on("click", "._click-select-editor ._select-item", function(event) {
      var selectEditor;
      selectEditor = $(this).closest("._click-select-editor");
      selectEditor.find(".selected").removeClass("selected");
      $(this).closest("._select-item").addClass("selected");
      return event.stopPropagation();
    });
  });

}).call(this);
