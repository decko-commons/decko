// layout.js.coffee
(function(){var a,e,t,s,o,i,n;i=function(){var e;if(e=$("body > footer").first(),$("body > article, body > aside").wrapAll("<div class='"+a()+"'/>"),$("body > div > article, body > div > aside").wrapAll('<div class="row row-offcanvas">'),e)return $("body").append(e)},n=function(a,e){return"<div class='container'><div class='row "+e+"'>"+a+"</div></div>"},a=function(){return $("body").hasClass("fluid")?"container-fluid":"container"},o=function(a){return"<button class='offcanvas-toggle btn btn-secondary d-sm-none' data-toggle='offcanvas-"+a+"'><i class='material-icons'>chevron_"+("left"===a?"right":"left")+"</i></button>"},t=function(a){return"both"===a?n(o("left")+o("right"),"flex-row justify-content-between"):"left"===a?n(o("left"),"flex-row"):n(o("right"),"flex-row-reverse")},s=function(a){var e,s;return e=$("body > article").first(),s=$("body > aside").first(),e.addClass("col-xs-12 col-sm-9"),s.addClass("col-xs-6 col-sm-3 sidebar-offcanvas sidebar-offcanvas-"+a),"left"===a?$("body").append(s).append(e):$("body").append(e).append(s),i(),e.prepend(t(a))},e=function(){var a,e,s,o,n;return a=$("body > article").first(),e=$("body > aside").first(),s=$($("body > aside")[1]),a.addClass("col-xs-12 col-sm-6"),o="col-xs-6 col-sm-3 sidebar-offcanvas",e.addClass(o+" sidebar-offcanvas-left"),s.addClass(o+" sidebar-offcanvas-right"),$("body").append(e).append(a).append(s),i(),n=t("both"),a.prepend(n)},$.fn.extend({toggleText:function(a,e){return this.text(this.text()===e?a:e),this}}),$(window).ready(function(){switch(!1){case!$("body").hasClass("right-sidebar"):s("right");break;case!$("body").hasClass("left-sidebar"):s("left");break;case!$("body").hasClass("two-sidebar"):e()}return $('[data-toggle="offcanvas-left"]').click(function(){return $(".row-offcanvas").removeClass("right-active").toggleClass("left-active"),$(this).find("i.material-icons").toggleText("chevron_left","chevron_right")}),$('[data-toggle="offcanvas-right"]').click(function(){return $(".row-offcanvas").removeClass("left-active").toggleClass("right-active"),$(this).find("i.material-icons").toggleText("chevron_left","chevron_right")})})}).call(this);
// modal.js.coffee
(function(){var o,d;$(window).ready(function(){return $("body").on("hidden.bs.modal",function(){return decko.removeModal()}),$("body").on("show.bs.modal","._modal-slot",function(d){var a;return a=$(d.relatedTarget),o($(this),a),$(this).modal("handleUpdate"),decko.contentLoaded($(d.target),a)}),$("._modal-slot").each(function(){return d($(this)),o($(this))}),$("body").on("click",".submit-modal",function(){return $(this).closest(".modal-content").find("form").submit()})}),d=function(o){var d;if((d=o.find(".modal-content")).length>0&&d.html().length>0)return $("#main > .card-slot").registerAsOrigin("modal",o),o.modal("show")},o=function(o,d){var a,l;if(l=o.find(".modal-dialog"),null!=(a=null!=d?d.data("modal-class"):o.data("modal-class"))&&null!=l)return l.addClass(a)},jQuery.fn.extend({showAsModal:function(o){var d;return null!=o&&(d=this.modalify(o)),$("body > ._modal-slot").is(":visible")?this.addModal(d,o):($("body > ._modal-slot")[0]?($("._modal-slot").trigger("decko.slot.destroy"),$("body > ._modal-slot").replaceWith(d)):$("body").append(d),o.registerAsOrigin("modal",d),d.modal("show",o))},addModal:function(o,d){var a;return"modal-replace"===d.data("slotter-mode")?(a=o.find(".modal-dialog"),o.adoptModalOrigin(),$("._modal-slot").trigger("decko.slot.destroy"),$("body > ._modal-slot > .modal-dialog").replaceWith(a),decko.contentLoaded(a,d)):(decko.pushModal(o),d.registerAsOrigin("modal",o),o.modal("show",d))},adoptModalOrigin:function(){var o;return o=$("body > ._modal-slot .card-slot[data-modal-origin-slot-id]").data("modal-origin-slot-id"),this.find(".modal-body .card-slot").attr("data-modal-origin-slot-id",o)},modalOriginSlot:function(){},modalSlot:function(){var o;return(o=$("#modal-container")).length>0?o:decko.createModalSlot()},modalify:function(o){var d;return null!=o.data("modal-body")&&this.find(".modal-body").append(o.data("modal-body")),this.hasClass("_modal-slot")?this:((d=$("<div/>",{id:"modal-container","class":"modal fade _modal-slot"})).append($("<div/>",{"class":"modal-dialog"}).append($("<div/>",{"class":"modal-content"}).append(this))),d)}}),$.extend(decko,{createModalSlot:function(){var o;return o=$("<div/>",{id:"modal-container","class":"modal fade _modal-slot"}),$("body").append(o),o},removeModal:function(){return $("._modal-stack")[0]?decko.popModal():($("._modal-slot").trigger("decko.slot.destroy"),$(".modal-dialog").empty())},pushModal:function(o){var d;return(d=$("body > ._modal-slot")).removeAttr("id"),d.removeClass("_modal-slot").addClass("_modal-stack").removeClass("modal").addClass("background-modal"),o.insertBefore(d),$(".modal-backdrop").removeClass("show")},popModal:function(){return $(".modal-backdrop").addClass("show"),$("body > ._modal-slot").trigger("decko.slot.destroy"),$("body > ._modal-slot").remove(),$($("._modal-stack")[0]).addClass("_modal-slot").removeClass("_modal-stack").attr("id","modal-container").addClass("modal").removeClass("background-modal"),$(document.body).addClass("modal-open")}})}).call(this);
// navbox.js.coffee
(function(){var t,e,n,a,i;$(window).ready(function(){var n;return n=$("._navbox"),decko.initSelect2Autocomplete(n,"navbox_complete",i,t,e,{minimumInputLength:1,multiple:!0,containerCssClass:"select2-navbox-autocomplete",dropdownCssClass:"select2-navbox-dropdown",width:"100%!important"}),n.on("select2:select",function(t){return a(t)})}),t=function(t){return t.loading?t.text:'<i class="material-icons">'+t.icon+'</i><span class="navbox-item-label">'+t.prefix+':</span> <span class="navbox-item-value">'+t.label+"</span>"},e=function(t){return t.icon?'<i class="material-icons">'+t.icon+'</i><span class="navbox-item-value">'+t.label+"</span>":t.text},i=function(t){var e,a;return e=[],a=t.term,t.search&&e.push(n({prefix:"search",id:a,text:a})),$.each(["add","new"],function(a,i){var o;if(o=t[i])return e.push(n({prefix:i,icon:"add",text:o[0],href:o[1]}))}),$.each(t.goto,function(t,a){var i;return i=n({prefix:"go to",id:t,icon:"arrow_forward",text:a[0],href:a[1],label:a[2]}),e.push(i)}),e},n=function(t){return t.id||(t.id=t.prefix),t.icon||(t.icon=t.prefix),t.label||(t.label='<strong class="highlight">'+t.text+"</strong>"),t},a=function(t){var e;return(e=t.params.data).href?window.location=decko.path(e.href):$(t.target).closest("form").submit(),$(t.target).attr("disabled","disabled")}}).call(this);
// overlay.js.coffee
(function(){jQuery.fn.extend({overlaySlot:function(){var e;return null!=(e=this.closest(".card-slot._overlay"))[0]?e:null!=(e=this.closest(".overlay-container").find("._overlay"))[0]&&$(e[0])},addOverlay:function(e,r){return this.parent().hasClass("overlay-container")?$(e).hasClass("_stack-overlay")?this.before(e):($("._overlay-origin").removeClass("_overlay-origin"),this.replaceOverlay(e)):(this.parent().hasClass("_overlay-container-placeholder")?this.parent().addClass("overlay-container"):this.wrapAll('<div class="overlay-container">'),this.addClass("_bottomlay-slot"),this.before(e)),r.registerAsOrigin("overlay",e),decko.contentLoaded(e,r)},replaceOverlay:function(e){return this.overlaySlot().trigger("decko.slot.destroy"),this.overlaySlot().replaceWith(e),$(".bridge-sidebar .tab-pane:not(.active) .bridge-pills > .nav-item > .nav-link.active").removeClass("active")},isInOverlay:function(){return this.closest(".card-slot._overlay").length},removeOverlay:function(){var e;if(e=this.overlaySlot())return e.removeOverlaySlot()},removeOverlaySlot:function(){var e;return this.trigger("decko.slot.destroy"),1===this.siblings().length&&(e=$(this.siblings()[0])).hasClass("_bottomlay-slot")&&(e.parent().hasClass("_overlay-container-placeholder")?e.parent().removeClass("overlay-container"):e.unwrap(),e.removeClass("_bottomlay-slot").updateBridge(!0,e)),this.remove()}})}).call(this);