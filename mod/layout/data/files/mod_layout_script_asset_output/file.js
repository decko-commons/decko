// layout.js.coffee
(function() {
  var containerClass, doubleSidebar, sidebarToggle, singleSidebar, toggleButton, wrapDeckoLayout, wrapSidebarToggle;

  wrapDeckoLayout = function() {
    var $footer;
    $footer = $('body > footer').first();
    $('body > article, body > aside').wrapAll("<div class='" + (containerClass()) + "'/>");
    $('body > div > article, body > div > aside').wrapAll('<div class="row row-offcanvas">');
    if ($footer) {
      return $('body').append($footer);
    }
  };

  wrapSidebarToggle = function(toggle, flex) {
    return "<div class='container'><div class='row " + flex + "'>" + toggle + "</div></div>";
  };

  containerClass = function() {
    if ($('body').hasClass('fluid')) {
      return "container-fluid";
    } else {
      return "container";
    }
  };

  toggleButton = function(side) {
    var icon_dir;
    icon_dir = side === 'left' ? 'right' : 'left';
    return "<button class='offcanvas-toggle btn btn-secondary " + ("d-sm-none' data-toggle='offcanvas-" + side + "'>") + ("<i class='material-icons'>chevron_" + icon_dir + "</i></button>");
  };

  sidebarToggle = function(side) {
    if (side === "both") {
      return wrapSidebarToggle(toggleButton("left") + toggleButton("right"), "flex-row justify-content-between");
    } else if (side === "left") {
      return wrapSidebarToggle(toggleButton("left"), "flex-row");
    } else {
      return wrapSidebarToggle(toggleButton("right"), "flex-row-reverse");
    }
  };

  singleSidebar = function(side) {
    var $article, $aside;
    $article = $('body > article').first();
    $aside = $('body > aside').first();
    $article.addClass("col-xs-12 col-sm-9");
    $aside.addClass("col-xs-6 col-sm-3 sidebar-offcanvas sidebar-offcanvas-" + side);
    if (side === 'left') {
      $('body').append($aside).append($article);
    } else {
      $('body').append($article).append($aside);
    }
    wrapDeckoLayout();
    return $article.prepend(sidebarToggle(side));
  };

  doubleSidebar = function() {
    var $article, $asideLeft, $asideRight, sideClass, toggles;
    $article = $('body > article').first();
    $asideLeft = $('body > aside').first();
    $asideRight = $($('body > aside')[1]);
    $article.addClass("col-xs-12 col-sm-6");
    sideClass = "col-xs-6 col-sm-3 sidebar-offcanvas";
    $asideLeft.addClass(sideClass + " sidebar-offcanvas-left");
    $asideRight.addClass(sideClass + " sidebar-offcanvas-right");
    $('body').append($asideLeft).append($article).append($asideRight);
    wrapDeckoLayout();
    toggles = sidebarToggle('both');
    return $article.prepend(toggles);
  };

  $.fn.extend({
    toggleText: function(a, b) {
      this.text(this.text() === b ? a : b);
      return this;
    }
  });

  $(window).ready(function() {
    switch (false) {
      case !$('body').hasClass('right-sidebar'):
        singleSidebar('right');
        break;
      case !$('body').hasClass('left-sidebar'):
        singleSidebar('left');
        break;
      case !$('body').hasClass('two-sidebar'):
        doubleSidebar();
    }
    $('[data-toggle="offcanvas-left"]').click(function() {
      $('.row-offcanvas').removeClass('right-active').toggleClass('left-active');
      return $(this).find('i.material-icons').toggleText('chevron_left', 'chevron_right');
    });
    return $('[data-toggle="offcanvas-right"]').click(function() {
      $('.row-offcanvas').removeClass('left-active').toggleClass('right-active');
      return $(this).find('i.material-icons').toggleText('chevron_left', 'chevron_right');
    });
  });

}).call(this);

// modal.js.coffee
(function() {
  var addModalDialogClasses, openModalIfPresent;

  $(window).ready(function() {
    $('body').on('hidden.bs.modal', function(_event) {
      return decko.removeModal();
    });
    $('body').on("show.bs.modal", "._modal-slot", function(event, slot) {
      var link;
      link = $(event.relatedTarget);
      addModalDialogClasses($(this), link);
      $(this).modal("handleUpdate");
      return decko.contentLoaded($(event.target), link);
    });
    $('._modal-slot').each(function() {
      openModalIfPresent($(this));
      return addModalDialogClasses($(this));
    });
    return $('body').on('click', '.submit-modal', function() {
      return $(this).closest('.modal-content').find('form').submit();
    });
  });

  openModalIfPresent = function(mslot) {
    var modal_content;
    modal_content = mslot.find(".modal-content");
    if (modal_content.length > 0 && modal_content.html().length > 0) {
      $("#main > .card-slot").registerAsOrigin("modal", mslot);
      return mslot.modal("show");
    }
  };

  addModalDialogClasses = function($modal_slot, $link) {
    var classes_from_link, dialog;
    dialog = $modal_slot.find(".modal-dialog");
    classes_from_link = $link != null ? $link.data("modal-class") : $modal_slot.data("modal-class");
    if ((classes_from_link != null) && (dialog != null)) {
      return dialog.addClass(classes_from_link);
    }
  };

  jQuery.fn.extend({
    showAsModal: function($slotter) {
      var el;
      if ($slotter != null) {
        el = this.modalify($slotter);
      }
      if ($("body > ._modal-slot").is(":visible")) {
        return this.addModal(el, $slotter);
      } else {
        if ($("body > ._modal-slot")[0]) {
          $("._modal-slot").trigger("decko.slot.destroy");
          $("body > ._modal-slot").replaceWith(el);
        } else {
          $("body").append(el);
        }
        $slotter.registerAsOrigin("modal", el);
        return el.modal("show", $slotter);
      }
    },
    addModal: function(el, $slotter) {
      var dialog;
      if ($slotter.data("slotter-mode") === "modal-replace") {
        addModalDialogClasses(el, $slotter);
        dialog = el.find(".modal-dialog");
        el.adoptModalOrigin();
        $("._modal-slot").trigger("decko.slot.destroy");
        $("body > ._modal-slot > .modal-dialog").replaceWith(dialog);
        return decko.contentLoaded(dialog, $slotter);
      } else {
        decko.pushModal(el);
        $slotter.registerAsOrigin("modal", el);
        return el.modal("show", $slotter);
      }
    },
    adoptModalOrigin: function() {
      var origin_slot_id;
      origin_slot_id = $("body > ._modal-slot .card-slot[data-modal-origin-slot-id]").data("modal-origin-slot-id");
      return this.find(".modal-body .card-slot").attr("data-modal-origin-slot-id", origin_slot_id);
    },
    modalSlot: function() {
      var slot;
      slot = $("#modal-container");
      if (slot.length > 0) {
        return slot;
      } else {
        return decko.createModalSlot();
      }
    },
    modalify: function($slotter) {
      var modalSlot;
      if ($slotter.data("modal-body") != null) {
        this.find(".modal-body").append($slotter.data("modal-body"));
      }
      if (this.hasClass("_modal-slot")) {
        return this;
      } else {
        modalSlot = $('<div/>', {
          id: "modal-container",
          "class": "modal fade _modal-slot"
        });
        modalSlot.append($('<div/>', {
          "class": "modal-dialog modal-dialog-centered"
        }).append($('<div/>', {
          "class": "modal-content"
        }).append(this)));
        return modalSlot;
      }
    }
  });

  $.extend(decko, {
    createModalSlot: function() {
      var slot;
      slot = $('<div/>', {
        id: "modal-container",
        "class": "modal fade _modal-slot"
      });
      $("body").append(slot);
      return slot;
    },
    removeModal: function() {
      if ($("._modal-stack")[0]) {
        return decko.popModal();
      } else {
        $("._modal-slot").trigger("decko.slot.destroy");
        return $(".modal-dialog").empty();
      }
    },
    pushModal: function(el) {
      var mslot;
      mslot = $("body > ._modal-slot");
      mslot.removeAttr("id");
      mslot.removeClass("_modal-slot").addClass("_modal-stack").removeClass("modal").addClass("background-modal");
      el.insertBefore(mslot);
      return $(".modal-backdrop").removeClass("show");
    },
    popModal: function() {
      var modal;
      $(".modal-backdrop").addClass("show");
      $("body > ._modal-slot").trigger("decko.slot.destroy");
      $("body > ._modal-slot").remove();
      modal = $($("._modal-stack")[0]);
      modal.addClass("_modal-slot").removeClass("_modal-stack").attr("id", "modal-container").addClass("modal").removeClass("background-modal");
      return $(document.body).addClass("modal-open");
    }
  });

}).call(this);

// overlay.js.coffee
(function() {
  jQuery.fn.extend({
    overlaySlot: function() {
      var oslot;
      oslot = this.closest(".card-slot._overlay");
      if (oslot[0] != null) {
        return oslot;
      }
      oslot = this.closest(".overlay-container").find("._overlay");
      return (oslot[0] != null) && $(oslot[0]);
    },
    addOverlay: function(overlay, $slotter) {
      if (this.parent().hasClass("overlay-container")) {
        if ($(overlay).hasClass("_stack-overlay")) {
          this.before(overlay);
        } else {
          $("._overlay-origin").removeClass("_overlay-origin");
          this.replaceOverlay(overlay);
        }
      } else {
        if (this.parent().hasClass("_overlay-container-placeholder")) {
          this.parent().addClass("overlay-container");
        } else {
          this.wrapAll('<div class="overlay-container">');
        }
        this.addClass("_bottomlay-slot");
        this.before(overlay);
      }
      $slotter.registerAsOrigin("overlay", overlay);
      return decko.contentLoaded(overlay, $slotter);
    },
    replaceOverlay: function(overlay) {
      this.overlaySlot().trigger("decko.slot.destroy");
      this.overlaySlot().replaceWith(overlay);
      return $(".board-sidebar .tab-pane:not(.active) .board-pills > .nav-item > .nav-link.active").removeClass("active");
    },
    isInOverlay: function() {
      return this.closest(".card-slot._overlay").length;
    },
    removeOverlay: function() {
      var slot;
      slot = this.overlaySlot();
      if (slot) {
        return slot.removeOverlaySlot();
      }
    },
    removeOverlaySlot: function() {
      var bottomlay;
      this.trigger("decko.slot.destroy");
      if (this.siblings().length === 1) {
        bottomlay = $(this.siblings()[0]);
        if (bottomlay.hasClass("_bottomlay-slot")) {
          if (bottomlay.parent().hasClass("_overlay-container-placeholder")) {
            bottomlay.parent().removeClass("overlay-container");
          } else {
            bottomlay.unwrap();
          }
          bottomlay.removeClass("_bottomlay-slot").updateBoard(true, bottomlay);
        }
      }
      return this.remove();
    }
  });

}).call(this);
