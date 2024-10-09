// autosave.js.coffee
(function() {
  jQuery.fn.extend({
    autosave: function() {
      var form_data, id, multi, reportee, slot, submit_url;
      slot = this.slot();
      if (this.attr('no-autosave')) {
        return;
      }
      multi = this.closest('.form-group');
      if (multi[0]) {
        if (!(id = multi.data('cardId'))) {
          return;
        }
        reportee = ': ' + multi.data('cardName');
      } else {
        id = slot.data('cardId');
        reportee = '';
      }
      if (!id) {
        return;
      }
      submit_url = decko.path('update/~' + id);
      form_data = $('#edit_card_' + id).serializeArray().reduce((function(obj, item) {
        obj[item.name] = item.value;
        return obj;
      }), {
        'draft': 'true',
        'success[view]': 'blank'
      });
      return $.ajax(submit_url, {
        data: form_data,
        type: 'POST'
      });
    }
  });

  $(window).ready(function() {
    return $('body').on('change', '.autosave .d0-card-content', function() {
      var content_field;
      content_field = $(this);
      return setTimeout((function() {
        return content_field.autosave();
      }), 500);
    });
  });

}).call(this);

// board.js.coffee
(function() {
  decko.slot.ready(function(slot, slotter) {
    var links;
    slot.updateBoard(false, slotter);
    links = slot.find('ul._auto-single-select > li.nav-item > a.nav-link');
    if (links.length === 1) {
      return $(links[0]).click();
    }
  });

  jQuery.fn.extend({
    updateBoard: function(overlayClosed, slotter) {
      if (overlayClosed == null) {
        overlayClosed = false;
      }
      if (!(this.closest(".board").length > 0)) {
        return;
      }
      if (this.data("breadcrumb")) {
        this.updateBreadcrumb();
      } else if (slotter && $(slotter).data("breadcrumb")) {
        $(slotter).updateBreadcrumb();
      }
      if (overlayClosed) {
        return $(".board-pills > .nav-item > .nav-link.active").removeClass("active");
      }
    },
    updateBreadcrumb: function() {
      var bc_item;
      bc_item = $(".modal-header ._board-breadcrumb li:last-child");
      bc_item.text(this.data("breadcrumb"));
      return bc_item.attr("class", "breadcrumb-item active " + (this.data('breadcrumb-class')));
    }
  });

  $(window).ready(function() {
    $('body').on("select2:select", "._close-rule-overlay-on-select", function(event) {
      return $(".overlay-container > ._overlay.card-slot.overlay_rule-view.RULE").removeOverlay();
    });
    return $('body').on("click", "._update-history-pills", function(event) {
      return $(this).closest(".slotter").data("update-foreign-slot", ".card-slot.history_tab-view");
    });
  });

}).call(this);

// components.js.coffee
(function() {
  var submitAfterTyping;

  submitAfterTyping = null;

  $(window).ready(function() {
    $('body').on("change", "._submit-on-change", function(event) {
      $(event.target).closest('form').submit();
      return false;
    });
    $('body').on("input", "._submit-after-typing", function(event) {
      var form;
      form = $(event.target).closest('form');
      form.slot().find(".autosubmit-success-notification").remove();
      if (submitAfterTyping) {
        clearTimeout(submitAfterTyping);
      }
      return submitAfterTyping = setTimeout(function() {
        $(event.target).closest('form').submit();
        return submitAfterTyping = null;
      }, 1000);
    });
    $('body').on("keydown", "._submit-after-typing", function(event) {
      if (event.which === 13) {
        if (submitAfterTyping) {
          clearTimeout(submitAfterTyping);
        }
        submitAfterTyping = null;
        $(event.target).closest('form').submit();
        return false;
      }
    });
    return $('body').on("change", "._edit-item", function(event) {
      var cb;
      cb = $(event.target);
      cb.attr("name", cb.is(":checked") && "add_item" || "drop_item");
      $(event.target).closest('form').submit();
      return false;
    });
  });

}).call(this);

// doubleclick.js.coffee
(function() {
  var doubleClickApplies, slotEditLink, slotEditView, triggerDoubleClickEditingOn;

  $(window).ready(function() {
    var doubleClickActive, doubleClickActiveMap;
    doubleClickActiveMap = {
      off: false,
      on: true,
      signed_in: decko.currentUserId
    };
    doubleClickActive = function() {
      return doubleClickActiveMap[decko.doubleClick];
    };
    if (doubleClickActive()) {
      return $('body').on('dblclick', 'div', function(_event) {
        if (doubleClickApplies($(this))) {
          triggerDoubleClickEditingOn($(this));
        }
        return false;
      });
    }
  });

  doubleClickApplies = function(el) {
    if (['.nodblclick', '.d0-card-header', '.card-editor'].some(function(klass) {
      return el.closest(klass)[0];
    })) {
      return false;
    }
    return el.slot().find('.card-editor')[0] == null;
  };

  triggerDoubleClickEditingOn = function(el) {
    var edit_link, edit_view, slot, url;
    slot = el.slot();
    edit_link = slotEditLink(slot);
    if (edit_link) {
      return edit_link.click();
    } else {
      edit_view = slotEditView(slot);
      url = decko.path("~" + (slot.data('cardId')) + "?view=" + edit_view);
      return slot.slotReload(url);
    }
  };

  slotEditLink = function(slot) {
    var edit_links;
    edit_links = slot.find(".edit-link").filter(function(i, el) {
      return $(el).slot().data('slotId') === slot.data('slotId');
    });
    if (edit_links[0]) {
      return $(edit_links[0]);
    } else {
      return false;
    }
  };

  slotEditView = function(slot) {
    switch (slot.data("slot").edit) {
      case "inline":
        return "edit_inline";
      case "full":
        return "board";
      default:
        return "edit";
    }
  };

}).call(this);

// editor.js.coffee
(function() {
  decko.editors.init["textarea"] = function() {
    return $(this).autosize();
  };

  $.extend(decko, {
    contentLoaded: function(el, slotter) {
      var notice;
      decko.initializeEditors(el);
      notice = slotter.attr('notify-success');
      if (notice != null) {
        el.notify(notice, "success");
      }
      return el.triggerSlotReady(slotter);
    },
    initializeEditors: function(range, map) {
      if (map == null) {
        map = decko.editors.init;
      }
      return $.each(map, function(selector, fn) {
        return $.each(range.find(selector), function() {
          return fn.call($(this));
        });
      });
    }
  });

  jQuery.fn.extend({
    contentField: function() {
      return this.closest('.card-editor').find('.d0-card-content');
    },
    setContentFieldsFromMap: function(map) {
      var this_form;
      if (map == null) {
        map = decko.editors.content;
      }
      this_form = $(this);
      return $.each(map, function(selector, fn) {
        return this_form.setContentFields(selector, fn);
      });
    },
    setContentFields: function(selector, fn) {
      return $.each(this.find(selector), function() {
        return $(this).setContentField(fn);
      });
    },
    setContentField: function(fn) {
      var field, init_val, new_val;
      field = this.contentField();
      init_val = field.val();
      new_val = fn.call(this);
      field.val(new_val);
      if (init_val !== new_val) {
        return field.change();
      }
    }
  });

  $(window).ready(function() {
    setTimeout((function() {
      return decko.initializeEditors($('body > :not(.modal)'));
    }), 10);
    return $('body').on('submit', '.card-form', function() {
      $(this).setContentFieldsFromMap();
      $(this).find('.d0-card-content').attr('no-autosave', 'true');
      return true;
    });
  });

  setInterval((function() {
    return $('.card-form').setContentFieldsFromMap();
  }), 20000);

}).call(this);

// name_editor.js.coffee
(function() {
  var checkName, checkNameAfterTyping;

  checkNameAfterTyping = null;

  $(window).ready(function() {
    return $('body').on('keyup', '.name-editor input', function(event) {
      var input;
      if (checkNameAfterTyping) {
        clearTimeout(checkNameAfterTyping);
      }
      input = $(this);
      if (event.which === 13) {
        checkName(input);
        return checkNameAfterTyping = null;
      } else {
        return checkNameAfterTyping = setTimeout(function() {
          checkName(input);
          return checkNameAfterTyping = null;
        }, 400);
      }
    });
  });

  decko.pingName = function(name, success) {
    return $.getJSON(decko.path(''), {
      format: 'json',
      view: 'status',
      'card[name]': name
    }, success);
  };

  checkName = function(box) {
    var name;
    name = box.val();
    return decko.pingName(name, function(data) {
      var ed, href, leg, msg, qualifier, slot_id, status;
      if (box.val() !== name) {
        return null;
      }
      status = data['status'];
      if (status) {
        ed = box.parent();
        leg = box.closest('fieldset').find('legend');
        msg = leg.find('.name-messages');
        if (!msg[0]) {
          msg = $('<span class="name-messages"></span>');
          leg.append(msg != null);
        }
        ed.removeClass('real-name virtual-name known-name');
        slot_id = box.slot().data('cardId');
        if (status !== 'unknown' && !(slot_id && parseInt(slot_id) === data['id'])) {
          ed.addClass(status + '-name known-name');
          qualifier = status === 'virtual' ? 'in virtual' : 'already in';
          href = decko.path(data['url_key']);
          return msg.html("\"<a href='" + href + "'>" + name + "</a>\" " + qualifier + " use");
        } else {
          return msg.html('');
        }
      }
    });
  };

}).call(this);

// tooltip.js.coffee
(function() {
  $(function() {
    var tooltipList, tooltipTriggerList;
    tooltipTriggerList = document.querySelectorAll('[data-bs-toggle="tooltip"]');
    return tooltipList = $.map(tooltipTriggerList, function(tooltipTriggerEl) {
      return new bootstrap.Tooltip(tooltipTriggerEl);
    });
  });

}).call(this);

// type_editor.js.coffee
(function() {
  var setSlotMode;

  $(window).ready(function() {
    $('body').on("change", '._live-type-field', function() {
      var $this;
      $this = $(this);
      setSlotMode($this);
      $this.data('params', $this.closest('form').serialize());
      return $this.data('url', $this.attr('href'));
    });
    return $('body').on('change', '.edit-type-field', function() {
      return $(this).closest('form').submit();
    });
  });

  setSlotMode = function($el, mode) {
    var $slotter;
    if (mode == null) {
      mode = null;
    }
    $slotter = $el.closest(".slotter");
    if ($slotter.length) {
      if ($slotter.attr('data-slotter-mode')) {
        $slotter.attr('data-original-slotter-mode', $slotter.attr('data-slotter-mode'));
        $slotter.attr('data-slotter-mode', mode);
      }
      if ($slotter.attr('data-slot-selector')) {
        $slotter.attr('data-original-slot-selector', $slotter.attr('data-slot-selector'));
        return $slotter.removeAttr('data-slot-selector');
      }
    }
  };

}).call(this);
