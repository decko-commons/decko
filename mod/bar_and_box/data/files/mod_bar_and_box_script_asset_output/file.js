// bar_and_box.js.coffee
(function(){$(window).ready(function(){return $(document).on("click",".box",function(){return window.location=decko.path($(this).data("cardLinkName"))}),$("body").on("click",".box a",function(n){return n.preventDefault()})})}).call(this);