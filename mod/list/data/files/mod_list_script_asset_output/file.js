// click_select.js.coffee
(function(){$("body").on("click","._click-multiselect-editor ._select-item",function(e){return $(this).closest("._select-item").toggleClass("selected"),e.stopPropagation()}),$("body").on("click","._click-select-editor ._select-item",function(e){return $(this).closest("._click-select-editor").find(".selected").removeClass("selected"),$(this).closest("._select-item").addClass("selected"),e.stopPropagation()})}).call(this);