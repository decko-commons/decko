// bar_and_box.js.coffee
(function(){$(window).ready(function(){return $(document).on("click","._card-link",function(){var n;return"on"===(n=$(this)).data("skip")?n.data("skip",null):n.closest("._card-link-modal")[0]?n.find("._modal-page-link").trigger("click"):window.location=decko.path(n.data("cardLinkName"))})}),decko.slot.ready(function(n){return n.find("._card-link a, ._card-link ._card-link-clickable").on("click",function(n){var a;return(a=$(this)).hasClass("_over-card-link")||a.closest("._over-card-link")[0]?a.closest("._card-link").data("skip","on"):n.preventDefault()})})}).call(this);
// click_select.js.coffee
(function(){$("body").on("click","._click-multiselect-editor ._select-item",function(e){return $(this).closest("._select-item").toggleClass("selected"),e.stopPropagation()}),$("body").on("click","._click-select-editor ._select-item",function(e){return $(this).closest("._click-select-editor").find(".selected").removeClass("selected"),$(this).closest("._select-item").addClass("selected"),e.stopPropagation()})}).call(this);