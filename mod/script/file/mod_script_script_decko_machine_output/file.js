// mod.js.coffee
(function() {
  window.decko || (window.decko = {});

  $(window).ready(function() {
    var firstShade;
    $('body').on('click', '._stop_propagation', function(event) {
      return event.stopPropagation();
    });
    $('body').on('click', '._prevent_default', function(event) {
      return event.preventDefault();
    });
    $('body').on('mouseenter', 'a[data-hover-text]', function() {
      var text;
      text = $(this).text();
      $(this).data("original-text", text);
      return $(this).text($(this).data("hover-text"));
    });
    $('body').on('mouseleave', 'a[data-hover-text]', function() {
      return $(this).text($(this).data("original-text"));
    });
    $('body').on('click', '.shade-view h1', function() {
      var toggleThis;
      toggleThis = $(this).slot().find('.shade-content').is(':hidden');
      decko.toggleShade($(this).closest('.pointer-list').find('.shade-content:visible').parent());
      if (toggleThis) {
        return decko.toggleShade($(this).slot());
      }
    });
    if (firstShade = $('.shade-view h1')[0]) {
      $(firstShade).trigger('click');
    }
    $('body').on('click', '.open-slow-items', function() {
      var panel;
      panel = $(this).closest('.panel-group');
      panel.find('.open-slow-items').removeClass('open-slow-items').addClass('close-slow-items');
      panel.find('.toggle-fast-items').text("show < 100ms");
      panel.find('.duration-ok').hide();
      return panel.find('.panel-danger > .panel-collapse').collapse('show').find('a > span').addClass('show-fast-items');
    });
    $('body').on('click', '.close-slow-items', function() {
      var panel;
      panel = $(this).closest('.panel-group');
      panel.find('.close-slow-items').removeClass('close-slow-items').addClass('open-slow-items');
      panel.find('.toggle-fast-items').text("hide < 100ms");
      panel.find('.panel-danger > .panel-collapse').collapse('hide').removeClass('show-fast-items');
      return panel.find('.duration-ok').show();
    });
    $('body').on('click', '.toggle-fast-items', function() {
      var panel;
      panel = $(this).closest('.panel-group');
      if ($(this).text() === 'hide < 100ms') {
        panel.find('.duration-ok').hide();
        return $(this).text("show < 100ms");
      } else {
        panel.find('.duration-ok').show();
        return $(this).text("hide < 100ms");
      }
    });
    return $('body').on('click', '.show-fast-items', function(event) {
      var panel;
      $(this).removeClass('show-fast-items');
      panel = $(this).closest('.panel-group');
      panel.find('.duration-ok').show();
      panel.find('.show-fast-items').removeClass('show-fast-items');
      panel.find('.panel-collapse').collapse('show');
      return event.stopPropagation();
    });
  });

  $.extend(decko, {
    toggleShade: function(shadeSlot) {
      shadeSlot.find('.shade-content').slideToggle(1000);
      return shadeSlot.find('.glyphicon').toggleClass('glyphicon-triangle-right glpyphicon-triangle-bottom');
    }
  });

}).call(this);

// editor.js.coffee
(function() {
  $.extend(decko, {
    initializeEditors: function(range, map) {
      if (map == null) {
        map = decko.editorInitFunctionMap;
      }
      return $.each(map, function(selector, fn) {
        return $.each(range.find(selector), function() {
          return fn.call($(this));
        });
      });
    },
    editorContentFunctionMap: {},
    editorInitFunctionMap: {
      'textarea': function() {
        return $(this).autosize();
      },
      '.file-upload': function() {
        return decko.upload_file(this);
      },
      '.etherpad-textarea': function() {
        return $(this).closest('form').find('.edit-submit-button').attr('class', 'etherpad-submit-button');
      }
    },
    addEditor: function(selector, init, get_content) {
      decko.editorContentFunctionMap[selector] = get_content;
      return decko.editorInitFunctionMap[selector] = init;
    }
  });

  jQuery.fn.extend({
    setContentFieldsFromMap: function(map) {
      var this_form;
      if (map == null) {
        map = decko.editorContentFunctionMap;
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
    contentField: function() {
      return this.closest('.card-editor').find('.d0-card-content');
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

// doubleclick.js.coffee
(function() {
  var doubleClickActive, doubleClickActiveMap, doubleClickApplies, triggerDoubleClickEditingOn;

  doubleClickActiveMap = {
    off: false,
    on: true,
    signed_in: decko.currentUserId
  };

  doubleClickActive = function() {
    return doubleClickActiveMap[decko.doubleClick];
  };

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
    edit_link = decko.slotEditLink(slot);
    if (edit_link) {
      return edit_link.click();
    } else {
      edit_view = decko.slotEditView(slot);
      url = decko.path("~" + (slot.data('cardId')) + "?view=" + edit_view);
      return slot.reloadSlot(url);
    }
  };

  $(window).ready(function() {
    if (doubleClickActive()) {
      return $('body').on('dblclick', 'div', function(_event) {
        if (doubleClickApplies($(this))) {
          triggerDoubleClickEditingOn($(this));
        }
        return false;
      });
    }
  });

}).call(this);

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

// navbox.js.coffee
(function() {
  var formatNavboxItem, formatNavboxSelectedItem, navboxItem, navboxSelect, navboxize;

  $(window).ready(function() {
    var navbox;
    navbox = $('._navbox');
    navbox.select2({
      placeholder: navbox.attr("placeholder"),
      escapeMarkup: function(markup) {
        return markup;
      },
      minimumInputLength: 1,
      maximumSelectionSize: 1,
      ajax: {
        delay: 200,
        url: decko.path(':search.json'),
        data: function(params) {
          return {
            query: {
              keyword: params.term
            },
            view: "complete"
          };
        },
        processResults: function(data) {
          return {
            results: navboxize(data)
          };
        },
        cache: true
      },
      templateResult: formatNavboxItem,
      templateSelection: formatNavboxSelectedItem,
      multiple: true,
      containerCssClass: 'select2-navbox-autocomplete',
      dropdownCssClass: 'select2-navbox-dropdown',
      width: "100%!important"
    });
    return navbox.on("select2:select", function(e) {
      return navboxSelect(e);
    });
  });

  formatNavboxItem = function(i) {
    if (i.loading) {
      return i.text;
    }
    return '<i class="material-icons">' + i.icon + '</i>' + '<span class="navbox-item-label">' + i.prefix + ':</span> ' + '<span class="navbox-item-value">' + i.label + '</span>';
  };

  formatNavboxSelectedItem = function(i) {
    if (!i.icon) {
      return i.text;
    }
    return '<i class="material-icons">' + i.icon + '</i>' + '<span class="navbox-item-value">' + i.label + '</span>';
  };

  navboxize = function(results) {
    var items, term;
    items = [];
    term = results.term;
    if (results["search"]) {
      items.push(navboxItem({
        prefix: "search",
        id: term,
        text: term
      }));
    }
    $.each(['add', 'new'], function(index, key) {
      var val;
      if (val = results[key]) {
        return items.push(navboxItem({
          prefix: key,
          icon: "add",
          text: val[0],
          href: val[1]
        }));
      }
    });
    $.each(results['goto'], function(index, val) {
      var i;
      i = navboxItem({
        prefix: "go to",
        id: index,
        icon: "arrow_forward",
        text: val[0],
        href: val[1],
        label: val[2]
      });
      return items.push(i);
    });
    return items;
  };

  navboxItem = function(data) {
    data.id || (data.id = data.prefix);
    data.icon || (data.icon = data.prefix);
    data.label || (data.label = '<strong class="highlight">' + data.text + '</strong>');
    return data;
  };

  navboxSelect = function(event) {
    var item;
    item = event.params.data;
    if (item.href) {
      window.location = decko.path(item.href);
    } else {
      $(event.target).closest('form').submit();
    }
    return $(event.target).attr('disabled', 'disabled');
  };

}).call(this);

// upload.js.coffee
(function() {
  $.extend(decko, {
    upload_file: function(fileupload) {
      var $_fileupload, url;
      $(fileupload).on('fileuploadsubmit', function(e, data) {
        var $_this, card_name, type_id;
        $_this = $(this);
        card_name = $_this.siblings(".attachment_card_name:first").attr("name");
        type_id = $_this.siblings("#attachment_type_id").val();
        return data.formData = {
          "card[type_id]": type_id,
          "attachment_upload": card_name
        };
      });
      $_fileupload = $(fileupload);
      if ($_fileupload.closest("form").attr("action").indexOf("update") > -1) {
        url = "card/update/" + $(fileupload).siblings("#file_card_name").val();
      } else {
        url = "card/create";
      }
      return $(fileupload).fileupload({
        url: decko.path(url),
        dataType: 'html',
        done: decko.doneFile,
        add: decko.chooseFile,
        progressall: decko.progressallFile
      });
    },
    chooseFile: function(e, data) {
      var editor;
      data.form.find('button[type=submit]').attr('disabled', true);
      editor = $(this).closest('.card-editor');
      $('#progress').show();
      editor.append('<input type="hidden" class="extra_upload_param" ' + 'value="true" name="attachment_upload">');
      editor.append('<input type="hidden" class="extra_upload_param" ' + 'value="preview_editor" name="view">');
      data.submit();
      editor.find('.choose-file').hide();
      return editor.find('.extra_upload_param').remove();
    },
    progressallFile: function(e, data) {
      var progress;
      progress = parseInt(data.loaded / data.total * 100, 10);
      return $('#progress .progress-bar').css('width', progress + '%');
    },
    doneFile: function(e, data) {
      var editor;
      editor = $(this).closest('.card-editor');
      editor.find('.chosen-file').replaceWith(data.result);
      return data.form.find('button[type=submit]').attr('disabled', false);
    }
  });

  $(window).ready(function() {
    return $('body').on('click', '.cancel-upload', function() {
      var editor;
      editor = $(this).closest('.card-editor');
      editor.find('.choose-file').show();
      editor.find('.chosen-file').empty();
      editor.find('.progress').show();
      editor.find('#progress .progress-bar').css('width', '0%');
      return editor.find('#progress').hide();
    });
  });

}).call(this);

// slot.js.coffee
(function() {
  $.extend(decko, {
    snakeCase: function(str) {
      return str.replace(/([a-z])([A-Z])/g, function(match) {
        return match[0] + '_' + match[1].toLowerCase();
      });
    },
    slotPath: function(path, slot) {
      var params;
      params = decko.slotData(slot);
      return decko.path(path) + ((path.match(/\?/) ? '&' : '?') + $.param(params));
    },
    slotData: function(slot) {
      var main, slotdata, xtra;
      xtra = {};
      main = $('#main').children('.card-slot').data('cardName');
      if (main != null) {
        xtra['main'] = main;
      }
      if (slot) {
        if (slot.isMain()) {
          xtra['is_main'] = true;
        }
        slotdata = slot.data('slot');
        if (slotdata != null) {
          decko.slotParams(slotdata, xtra, 'slot');
          if (slotdata['type']) {
            xtra['type'] = slotdata['type'];
          }
        }
      }
      return xtra;
    },
    slotEditView: function(slot) {
      var data;
      data = decko.slotData(slot);
      switch (data["slot[edit]"]) {
        case "inline":
          return "edit_inline";
        case "full":
          return "bridge";
        default:
          return "edit";
      }
    },
    slotEditLink: function(slot) {
      var edit_links;
      edit_links = slot.find(".edit-link").filter(function(i, el) {
        return $(el).slot().data('slotId') === slot.data('slotId');
      });
      if (edit_links[0]) {
        return $(edit_links[0]);
      } else {
        return false;
      }
    },
    slotParams: function(raw, processed, prefix) {
      return $.each(raw, function(key, value) {
        var cgiKey;
        cgiKey = prefix + '[' + decko.snakeCase(key) + ']';
        if (key === 'items') {
          return decko.slotParams(value, processed, cgiKey);
        } else {
          return processed[cgiKey] = value;
        }
      });
    },
    contentLoaded: function(el, slotter) {
      var notice;
      decko.initializeEditors(el);
      notice = slotter.attr('notify-success');
      if (notice != null) {
        el.notify(notice, "success");
      }
      return el.triggerSlotReady(slotter);
    },
    slotReady: function(func) {
      return $('document').ready(function() {
        return $('body').on('slotReady', '.card-slot', function(e, slotter) {
          e.stopPropagation();
          if (slotter != null) {
            return func.call(this, $(this), $(slotter));
          } else {
            return func.call(this, $(this));
          }
        });
      });
    },
    slotDestroy: function(func) {
      return $('document').ready(function() {
        return $('body').on('slotDestroy', '.card-slot, ._modal-slot', function(e) {
          e.stopPropagation();
          return func.call(this, $(this));
        });
      });
    }
  });

  jQuery.fn.extend({
    slot: function(status, mode) {
      if (status == null) {
        status = "success";
      }
      if (mode == null) {
        mode = "replace";
      }
      if (mode === "modal") {
        return this.modalSlot();
      } else {
        return this.selectSlot("slot-" + status + "-selector") || this.selectSlot("slot-selector") || this.closest(".card-slot");
      }
    },
    selectSlot: function(selectorName) {
      var selector, slot;
      if (selector = this.data(selectorName)) {
        slot = this.findSlot(selector);
        return slot && slot[0] && slot;
      }
    },
    isSlot: function() {
      return $(this).hasClass("card-slot");
    },
    isMain: function() {
      return this.slot().parent('#main')[0];
    },
    isMainOrMainModal: function() {
      var el;
      el = $(this);
      if (el.closest(".modal")[0]) {
        el = el.findOriginSlot("modal");
      }
      return el && el.isMain();
    },
    findSlot: function(selector) {
      var parent_slot, target_slot;
      if (selector === "modal-origin") {
        return this.findOriginSlot("modal");
      } else if (selector === "overlay-origin") {
        return this.findOriginSlot("overlay");
      } else {
        target_slot = this.closest(selector);
        parent_slot = this.closest('.card-slot');
        while (target_slot.length === 0 && parent_slot.length > 0) {
          target_slot = $(parent_slot).find(selector);
          parent_slot = $(parent_slot).parent().closest('.card-slot');
        }
        if (target_slot.length === 0) {
          return $(selector);
        } else {
          return target_slot;
        }
      }
    },
    findOriginSlot: function(type) {
      var origin_slot, origin_slot_id, overlaySlot;
      overlaySlot = this.closest("[data-" + type + "-origin-slot-id]");
      origin_slot_id = overlaySlot.data(type + "-origin-slot-id");
      origin_slot = $("[data-slot-id=" + origin_slot_id + "]");
      if (origin_slot[0] != null) {
        return origin_slot;
      } else {
        return console.log("couldn't find origin with slot id " + origin_slot_id);
      }
    },
    reloadSlot: function(url) {
      var $slot;
      $slot = $(this);
      if ($slot.length > 1) {
        $slot.each(function() {
          return $(this).reloadSlot(url);
        });
        return;
      }
      if (!$slot.isSlot) {
        $slot = $slot.slot();
      }
      if (!$slot[0]) {
        return;
      }
      if (url == null) {
        url = $slot.slotUrl();
      }
      $slot.addClass('slotter');
      $slot.attr('href', url);
      $slot.data("url", url);
      this[0].href = url;
      $slot.data("remote", true);
      return $.rails.handleRemote($slot);
    },
    clearSlot: function() {
      this.triggerSlotDestroy();
      return this.empty();
    },
    slotUrl: function() {
      return decko.slotPath((this.slotMark()) + "?view=" + (this.data("slot")["view"]));
    },
    slotMark: function() {
      if (this.data('cardId')) {
        return "~" + (this.data('cardId'));
      } else {
        return this.data("cardName");
      }
    },
    setSlotContent: function(val, mode, $slotter) {
      var v;
      v = $(val)[0] && $(val) || val;
      if (typeof v === "string") {
        this.slot("success", mode).replaceWith(v);
      } else {
        if (v.hasClass("_overlay")) {
          mode = "overlay";
        } else if (v.hasClass("_modal")) {
          mode = "modal";
        }
        this.slot("success", mode).setSlotContentFromElement(v, mode, $slotter);
      }
      return v;
    },
    setSlotContentFromElement: function(el, mode, $slotter) {
      var slot_id;
      if (mode === "overlay") {
        return this.addOverlay(el, $slotter);
      } else if (el.hasClass("_modal-slot") || mode === "modal") {
        return el.showAsModal($slotter);
      } else {
        slot_id = this.data("slot-id");
        if (slot_id) {
          el.attr("data-slot-id", slot_id);
        }
        this.triggerSlotDestroy();
        this.replaceWith(el);
        return decko.contentLoaded(el, $slotter);
      }
    },
    triggerSlotReady: function(slotter) {
      if (this.isSlot()) {
        this.trigger("slotReady", slotter);
      }
      return this.find(".card-slot").trigger("slotReady", slotter);
    },
    triggerSlotDestroy: function() {
      return this.trigger("slotDestroy");
    }
  });

}).call(this);

// decko.js.coffee
(function() {
  var setSlotMode, warn;

  $.extend(decko, {
    path: function(rawPath) {
      if (rawPath.match(/^\/|:\/\//)) {
        return rawPath;
      } else {
        return decko.rootUrl + rawPath;
      }
    },
    pingName: function(name, success) {
      return $.getJSON(decko.path(''), {
        format: 'json',
        view: 'status',
        'card[name]': name
      }, success);
    }
  });

  jQuery.fn.extend({
    notify: function(message, status) {
      var form, notice, slot;
      slot = this.slot(status);
      notice = slot.find('.card-notice');
      if (!notice[0]) {
        notice = $('<div class="card-notice"></div>');
        form = slot.find('.card-form');
        if (form[0]) {
          $(form[0]).append(notice);
        } else {
          slot.append(notice);
        }
      }
      notice.html(message);
      return notice.show('blind');
    },
    report: function(message) {
      var report;
      report = this.slot().find('.card-report');
      if (!report[0]) {
        return false;
      }
      report.hide();
      report.html(message);
      report.show('drop', 750);
      return setTimeout((function() {
        return report.hide('drop', 750);
      }), 3000);
    }
  });

  $(window).ready(function() {
    $.ajaxSetup({
      cache: false
    });
    $('body').on('click', '.submitter', function() {
      return $(this).closest('form').submit();
    });
    $('body').on('click', 'button.redirecter', function() {
      return window.location = $(this).attr('href');
    });
    $('body').on("change", '.live-type-field', function() {
      var $this;
      $this = $(this);
      setSlotMode($this);
      $this.data('params', $(this).closest('form').serialize());
      return $this.data('url', $(this).attr('href'));
    });
    $('body').on('change', '.edit-type-field', function() {
      return $(this).closest('form').submit();
    });
    $('body').on('mouseenter', '[hover_content]', function() {
      $(this).attr('hover_restore', $(this).html());
      return $(this).html($(this).attr('hover_content'));
    });
    $('body').on('mouseleave', '[hover_content]', function() {
      return $(this).html($(this).attr('hover_restore'));
    });
    return $('body').on('click', '.render-error-link', function(event) {
      var msg;
      msg = $(this).closest('.render-error').find('.render-error-message');
      msg.show();
      return event.preventDefault();
    });
  });

  decko.slotReady(function(slot) {
    return slot.find('card-view-placeholder').each(function() {
      var $place;
      $place = $(this);
      if ($place.data("loading")) {
        return;
      }
      $place.data("loading", true);
      return $.get($place.data("url"), function(data, _status) {
        return $place.replaceWith(data);
      });
    });
  });

  setSlotMode = function($el, mode) {
    var $slotter;
    if (mode == null) {
      mode = null;
    }
    $slotter = $el.closest(".slotter");
    if ($slotter.length && $slotter.attr('data-slotter-mode')) {
      $slotter.attr('data-original-slotter-mode', $slotter.attr('slotter-mode'));
      return $slotter.attr('data-slotter-mode', mode);
    }
  };

  warn = function(stuff) {
    if (typeof console !== "undefined" && console !== null) {
      return console.log(stuff);
    }
  };

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
          $("._modal-slot").trigger("slotDestroy");
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
        dialog = el.find(".modal-dialog");
        el.adoptModalOrigin();
        $("._modal-slot").trigger("slotDestroy");
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
    modalOriginSlot: function() {},
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
          "class": "modal-dialog"
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
        $("._modal-slot").trigger("slotDestroy");
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
      $("body > ._modal-slot").trigger("slotDestroy");
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
      this.overlaySlot().trigger("slotDestroy");
      this.overlaySlot().replaceWith(overlay);
      return $(".bridge-sidebar .tab-pane:not(.active) .bridge-pills > .nav-item > .nav-link.active").removeClass("active");
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
      this.trigger("slotDestroy");
      if (this.siblings().length === 1) {
        bottomlay = $(this.siblings()[0]);
        if (bottomlay.hasClass("_bottomlay-slot")) {
          if (bottomlay.parent().hasClass("_overlay-container-placeholder")) {
            bottomlay.parent().removeClass("overlay-container");
          } else {
            bottomlay.unwrap();
          }
          bottomlay.removeClass("_bottomlay-slot").updateBridge(true, bottomlay);
        }
      }
      return this.remove();
    }
  });

}).call(this);

// recaptcha.js.coffee
(function() {
  jQuery.fn.extend({
    updateRecaptchaToken: function(event) {
      var $slotter, recaptcha;
      recaptcha = this.find("input._recaptcha-token");
      if (recaptcha[0] == null) {
        return recaptcha.val("recaptcha-token-field-missing");
      } else if (typeof grecaptcha === "undefined" || grecaptcha === null) {
        return recaptcha.val("grecaptcha-undefined");
      } else {
        $slotter = $(this);
        if (event) {
          event.stopPropagation();
        }
        grecaptcha.execute(recaptcha.data("site-key"), {
          action: recaptcha.data("action")
        }).then(function(token) {
          recaptcha.val(token);
          recaptcha.addClass("_token-updated");
          if (event) {
            return $slotter.submit();
          }
        });
        return false;
      }
    }
  });

}).call(this);

// slotter.js.coffee
(function() {
  $(window).ready(function() {
    $('body').on('ajax:success', '.slotter', function(event, data, c, d) {
      return $(this).slotterSuccess(event, data);
    });
    $('body').on('ajax:error', '.slotter', function(event, xhr) {
      return $(this).showErrorResponse(xhr.status, xhr.responseText);
    });
    $('body').on('click', 'button.slotter', function(event) {
      if (!$.rails.allowAction($(this))) {
        return false;
      }
      return $.rails.handleRemote($(this));
    });
    $('body').on('click', '._clickable.slotter', function(event) {
      $(this)[0].href = $(this).attr("href");
      return $.rails.handleRemote($(this));
    });
    $('body').on('click', '[data-dismiss="overlay"]', function(event) {
      return $(this).findSlot(".card-slot._overlay").removeOverlay();
    });
    $('body').on('click', '._close-overlay-on-success', function(event) {
      return $(this).closeOnSuccess("overlay");
    });
    $('body').on('click', '._close-modal-on-success', function(event) {
      return $(this).closeOnSuccess("modal");
    });
    $('body').on('click', '._close-on-success', function(event) {
      return $(this).closeOnSuccess();
    });
    $('body').on('click', '._update-origin', function(event) {
      return $(this).closest('.slotter').data("slotter-mode", "update-origin");
    });
    $('body').on('submit', 'form.slotter', function(event) {
      var form;
      form = $(this);
      if (form.data("main-success") && form.isMainOrMainModal()) {
        form.mainSuccess();
      }
      if (form.data('recaptcha') === 'on') {
        return form.handleRecaptchaBeforeSubmit(event);
      }
    });
    return $('body').on('ajax:beforeSend', '.slotter', function(event, xhr, opt) {
      return $(this).slotterBeforeSend(opt);
    });
  });

  jQuery.fn.extend({
    mainSuccess: function() {
      var form;
      form = $(this);
      return $.each(form.data("main-success"), function(key, value) {
        var input, inputSelector;
        inputSelector = "[name=success\\[" + key + "\\]]";
        input = form.find(inputSelector);
        if (!input[0]) {
          input = $('<input type="hidden" name="success[' + key + ']"/>');
          form.append(input);
        }
        return input.val(value);
      });
    },
    slotterSuccess: function(event, data) {
      var $slot, mode, reload_url, slot_top_pos;
      if (!this.hasClass("slotter")) {
        console.log("warning: slotterSuccess called on non-slotter element " + this);
        return;
      }
      if (event.slotSuccessful) {
        return;
      }
      if (this.data("reload")) {
        window.location.reload(true);
      }
      if (this.data("update-modal-origin")) {
        this.updateModalOrigin();
      }
      if (this.data("update-origin")) {
        this.updateOrigin();
      }
      if (this.data('original-slotter-mode')) {
        this.attr('data-slotter-mode', this.data('original-slotter-mode'));
      }
      mode = this.data("slotter-mode");
      this.showSuccessResponse(data, mode);
      if (this.hasClass("_close-overlay")) {
        this.removeOverlay();
      }
      if (this.hasClass("_close-modal")) {
        this.closest('.modal').modal('hide');
      }
      if (this.hasClass("card-paging-link")) {
        slot_top_pos = this.slot().offset().top;
        $("body").scrollTop(slot_top_pos);
      }
      if (this.data("update-foreign-slot")) {
        $slot = this.findSlot(this.data("update-foreign-slot"));
        reload_url = this.data("update-foreign-slot-url");
        $slot.reloadSlot(reload_url);
      }
      return event.slotSuccessful = true;
    },
    showSuccessResponse: function(data, mode) {
      if (mode === "silent-success") {

      } else if (mode === "update-modal-origin") {
        return this.updateModalOrigin();
      } else if (mode === "update-origin") {
        return this.updateOrigin();
      } else if (data.redirect) {
        return window.location = data.redirect;
      } else if (data.reload) {
        return window.location.reload(true);
      } else {
        return this.updateSlot(data, mode);
      }
    },
    showErrorResponse: function(status, result) {
      if (status === 403) {
        return $(result).showAsModal($(this));
      } else if (status === 900) {
        return $(result).showAsModal($(this));
      } else {
        this.notify(result, "error");
        if (status === 409) {
          return this.slot().find('.current_revision_id').val(this.slot().find('.new-current-revision-id').text());
        }
      }
    },
    updateModalOrigin: function() {
      var overlayOrigin;
      if (this.overlaySlot()) {
        overlayOrigin = this.findOriginSlot("overlay");
        return overlayOrigin.updateOrigin();
      } else if (this.closest("#modal-container")[0]) {
        return this.updateOrigin();
      }
    },
    updateOrigin: function() {
      var origin, type;
      type = this.overlaySlot() ? "overlay" : this.closest("#modal-container")[0] ? "modal" : void 0;
      if (type == null) {
        return;
      }
      origin = this.findOriginSlot(type);
      if (origin && (origin[0] != null)) {
        return origin.reloadSlot();
      }
    },
    registerAsOrigin: function(type, slot) {
      if (slot.hasClass("_modal-slot")) {
        slot = slot.find(".modal-body .card-slot");
      }
      return slot.attr("data-" + type + "-origin-slot-id", this.closest(".card-slot").data("slot-id"));
    },
    updateSlot: function(data, mode) {
      mode || (mode = "replace");
      return this.setSlotContent(data, mode, $(this));
    },
    closeOnSuccess: function(type) {
      var slotter;
      slotter = this.closest('.slotter');
      if (type == null) {
        type = this.isInOverlay() ? "overlay" : "modal";
      }
      return slotter.addClass("_close-" + type);
    },
    slotterBeforeSend: function(opt) {
      var data;
      if (opt.skip_before_send) {
        return;
      }
      if (!(opt.url.match(/home_view/) || this.data("slotter-mode") === "modal")) {
        opt.url = decko.slotPath(opt.url, this.slot());
      }
      if (this.is('form')) {
        if (data = this.data('file-data')) {
          this.uploadWithBlueimp(data, opt);
          return false;
        }
      }
    },
    uploadWithBlueimp: function(data, opt) {
      var args, iframeUploadFilter, input, widget;
      input = this.find('.file-upload');
      if (input[1]) {
        this.notify("Decko does not yet support multiple files in a single form.", "error");
        return false;
      }
      widget = input.data('blueimpFileupload');
      if (!widget._isXHRUpload(widget.options)) {
        this.find('[name=success]').val('_self');
        opt.url += '&simulate_xhr=true';
        iframeUploadFilter = function(data) {
          return data.find('body').html();
        };
        opt.dataFilter = iframeUploadFilter;
      }
      args = $.extend(opt, widget._getAJAXSettings(data), {
        url: opt.url
      });
      args.skip_before_send = true;
      return $.ajax(args);
    },
    handleRecaptchaBeforeSubmit: function(event) {
      var recaptcha;
      recaptcha = this.find("input._recaptcha-token");
      if (recaptcha[0] == null) {
        return recaptcha.val("recaptcha-token-field-missing");
      } else if (recaptcha.hasClass("_token-updated")) {
        return recaptcha.removeClass("_token-updated");
      } else if (typeof grecaptcha === "undefined" || grecaptcha === null) {
        return recaptcha.val("grecaptcha-undefined");
      } else {
        return this.updateRecaptchaToken(event);
      }
    }
  });

}).call(this);

// bridge.js.coffee
(function() {
  decko.slotReady(function(slot, slotter) {
    var links;
    slot.updateBridge(false, slotter);
    links = slot.find('ul._auto-single-select > li.nav-item > a.nav-link');
    if (links.length === 1) {
      return $(links[0]).click();
    }
  });

  jQuery.fn.extend({
    updateBridge: function(overlayClosed, slotter) {
      if (overlayClosed == null) {
        overlayClosed = false;
      }
      if (!(this.closest(".bridge").length > 0)) {
        return;
      }
      if (this.data("breadcrumb")) {
        this.updateBreadcrumb();
      } else if (slotter && $(slotter).data("breadcrumb")) {
        $(slotter).updateBreadcrumb();
      }
      if (overlayClosed) {
        return $(".bridge-pills > .nav-item > .nav-link.active").removeClass("active");
      }
    },
    updateBreadcrumb: function() {
      var bc_item;
      bc_item = $(".modal-header ._bridge-breadcrumb li:last-child");
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

// nest_editor.js.coffee
(function() {
  $(document).ready(function() {
    $('body').on('click', 'button._nest-apply', function() {
      if ($(this).data("index") != null) {
        return nest.applyNestToNestListEditor($(this).data("index"));
      } else {
        return nest.applyNestToTinymceEditor($(this).data("tinymce-id"), $(this).data("tm-snippet-start"), $(this).data("tm-snippet-size"));
      }
    });
    $('body').on('click', 'button._change-create-to-update', function() {
      var tm_id;
      tm_id = $(this).closest("form").find("#success_tinymce_id").val();
      return nest.changeCreateToUpdate(tm_id);
    });
    return $('body').on('click', 'button._open-nest-editor', function() {
      var encoded_nest, form, nest_options, reference;
      form = $(this).closest("._nest-form");
      reference = form.find("._reference").val();
      nest_options = form.find("._nest-options").val();
      encoded_nest = encodeURIComponent("{{" + reference + "|" + nest_options + "}}");
      return nest.openNestEditorForSlot($(this).closest(".card-slot"), $(this).closest(".slotter"), "index=" + (form.data('index')) + "&tm_snippet_raw=" + encoded_nest);
    });
  });

  window.nest || (window.nest = {});

  $.extend(nest, {
    openNestEditor: function(tm, params) {
      if (params == null) {
        params = nest.editParams(tm);
      }
      return this.openEditorForTm(tm, params, "nest_editor", "modal_nest_editor");
    },
    openNestEditorForSlot: function(slot, slotter, params) {
      var card;
      card = slot[0] ? $(slot[0]).attr('data-card-name') : ":update";
      return nest.request(card, "nest_editor", "modal_nest_editor", slotter, params);
    },
    openEditorForTm: function(tm, params, overlay_view, modal_view) {
      var card, slot, slotter;
      params += "&tinymce_id=" + tm.id;
      slot = $("#" + tm.id).closest(".card-slot");
      slotter = $("#" + tm.id);
      card = slot[0] ? $(slot[0]).attr('data-card-name') : ":update";
      return nest.request(card, overlay_view, modal_view, slotter, params);
    },
    openImageEditor: function(tm) {
      var params;
      if (typeof params === "undefined" || params === null) {
        params = nest.editParams(tm, "{{", "}}", false);
      }
      return this.openEditorForTm(tm, params, "nest_image", "modal_nest_image");
    },
    changeCreateToUpdate: function(tm_id) {
      var form, new_action;
      form = $("#" + tm_id).closest("form");
      new_action = form.attr("action").replace("card/create", "card/update");
      return form.attr("action", new_action);
    },
    insertNest: function(tm, nest_string) {
      return tm.insertContent(nest_string);
    },
    request: function(card, overlay_view, modal_view, slotter, params) {
      var mode, slot, view;
      slot = $(".bridge-sidebar > ._overlay-container-placeholder > .card-slot");
      if (slot[0]) {
        view = overlay_view;
        mode = "overlay";
      } else {
        slot = $($(".card-slot")[0]);
        view = modal_view;
        mode = "modal";
      }
      return nest.sendRequest(slotter, slot, mode, card, view, params);
    },
    sendRequest: function(slotter, slot, mode, card, view, params) {
      var url;
      if (params == null) {
        params = "";
      }
      url = "/" + card + "?view=" + view + "&" + params;
      return $.ajax({
        url: url,
        type: 'GET',
        success: function(html) {
          return slot.setSlotContent(html, mode, slotter);
        }
      });
    },
    editParams: function(tm, prefix, postfix, edit) {
      var after, before, index, name, nest_size, nest_start, offset, sel, text;
      if (prefix == null) {
        prefix = "{{";
      }
      if (postfix == null) {
        postfix = "}}";
      }
      if (edit == null) {
        edit = true;
      }
      sel = tm.selection.getSel();
      if (!((sel != null) && (sel.anchorNode != null))) {
        return nest.paramsStr(0);
      }
      text = sel.anchorNode.data;
      if (!text) {
        return nest.paramsStr(sel.anchorOffset);
      }
      offset = sel.anchorOffset;
      before = text.substr(0, offset);
      after = text.substr(offset);
      index = {
        before: {
          close: before.lastIndexOf(postfix),
          open: before.lastIndexOf(prefix)
        },
        after: {
          close: after.indexOf(postfix),
          open: after.indexOf(prefix)
        }
      };
      if (index.before.open > index.before.close && index.after.close !== -1 && (index.after.open === -1 || index.after.close < index.after.open)) {
        nest_start = index.before.open;
        if (typeof name === "undefined" || name === null) {
          nest_size = index.after.close + offset + 2 - nest_start;
          name = text.substr(nest_start, nest_size);
        }
        if (edit) {
          return nest.paramsStr(nest_start, name);
        } else {
          return nest.paramsStr(nest_start + nest_size);
        }
      } else {
        return nest.paramsStr(offset);
      }
    },
    paramsStr: function(start, name) {
      var params;
      params = "";
      if (start != null) {
        params += "&tm_snippet_start=" + start;
      }
      if ((name != null) && name.length > 0) {
        params += "&tm_snippet_raw=" + (encodeURIComponent(name));
      }
      return params;
    },
    offsetAfterInsert: function(editor, content) {
      var offset;
      offset = editor.selection.getSel().anchorOffset;
      return offset - content.lengthr;
    },
    applyNestToTinymceEditor: function(tinymce_id, nest_start, nest_size) {
      return nest.applySnippet("nest", tinymce_id, nest_start, nest_size);
    },
    applyNestToNestListEditor: function(index) {
      var row;
      row = $("._nest-form[data-index='" + index + "']");
      row.find("._reference").val(nest.name());
      row.find("._nest-options").val(nest.options());
      return decko.updateAddItemButton(row);
    },
    applySnippet: function(snippet_type, tinymce_id, start, size) {
      var content, editor, offset;
      content = $("._" + snippet_type + "-preview").val();
      editor = tinymce.get(tinymce_id);
      if (start != null) {
        nest.replaceSnippet(editor, start, size, content);
      } else {
        editor.insertContent(content);
        offset = nest.offsetAfterInsert(editor, content);
        $("button._" + snippet_type + "-apply").attr("data-tm-snippet-start", offset);
      }
      return $("button._" + snippet_type + "-apply").attr("data-tm-snippet-size", content.length);
    },
    replaceSnippet: function(editor, start, size, content) {
      var sel, text;
      sel = editor.selection.getSel();
      if ((sel != null) && (sel.anchorNode != null) && (sel.anchorNode.data != null)) {
        text = sel.anchorNode.data;
        if (size == null) {
          size = 0;
        }
        text = "" + (text.substr(0, start)) + content + (text.substr(start + size));
        return sel.anchorNode.data = text;
      } else {
        return editor.insertContent(content);
      }
    },
    updatePreview: function(new_val) {
      var preview;
      if (new_val == null) {
        new_val = "{{" + (nest.name()) + "|" + (nest.options()) + "}}";
      }
      preview = $("._nest-preview");
      preview.val(new_val);
      preview.data("nest-options", nest.options());
      return preview.data("reference", nest.name());
    }
  });

}).call(this);

// nest_editor_rules.js.coffee
(function() {


}).call(this);

// nest_editor_options.js.coffee
(function() {
  $(document).ready(function() {
    $('body').on('keyup', 'input._nest-option-value', function() {
      return nest.updatePreview();
    });
    $('body').on("select2:select", "._nest-option-name", function() {
      nest.toggleOptionName($(this).closest("._options-select"), $(this).val(), true);
      return nest.updatePreview();
    });
    $('body').on("select2:selecting", "._nest-option-name", function() {
      return nest.toggleOptionName($(this).closest("._options-select"), $(this).val(), false);
    });
    $('body').on("select2:select", "._nest-option-name._new-row", function() {
      var row, template;
      $(this).closest(".input-group").find(".input-group-prepend").removeClass("d-none");
      row = $(this).closest("._nest-option-row");
      row.find("._nest-option-value").removeAttr("disabled");
      template = row.parent().find("._nest-option-row._template");
      $(this).removeClass("_new-row");
      return nest.addRow(template);
    });
    $('body').on("click", "._configure-items-button", function() {
      return nest.addItemsOptions($(this));
    });
    return $('body').on('click', 'button._nest-delete-option', function() {
      return nest.removeRow($(this).closest("._nest-option-row"));
    });
  });

  $.extend(nest, {
    showTemplate: function(elem) {
      return elem.removeClass("_template");
    },
    addRow: function(template) {
      var double, select_tag;
      select_tag = template.find("select");
      select_tag.select2("destroy");
      select_tag.removeAttr("data-select2-id");
      double = template.clone();
      decko.initSelect2(select_tag);
      nest.showTemplate(template);
      template.after(double);
      return decko.initSelect2(double.find("select"));
    },
    removeRow: function(row) {
      var name;
      name = row.find("._nest-option-name").val();
      nest.toggleOptionName(row.closest("._options-select"), name, false);
      row.remove();
      return nest.updatePreview();
    },
    addItemsOptions: function(button) {
      var container, next, title;
      container = button.closest("._configure-items");
      next = container.cloneSelect2(true);
      title = button.text();
      button.replaceWith($("<h6>" + (title.substr(9)) + "<h6>"));
      nest.showTemplate(container.find("._options-select._template"));
      next.find("._configure-items-button").text(title.replace("items", "subitems"));
      container.after(next);
      return nest.updatePreview();
    },
    options: function() {
      var ele, i, len, level_options, options, ref;
      options = [];
      ref = $("._options-select:not(._template");
      for (i = 0, len = ref.length; i < len; i++) {
        ele = ref[i];
        options.push(nest.extractOptions($(ele)));
      }
      level_options = options.map(function(opts) {
        return nest.toNestSyntax(opts);
      });
      return level_options.join("|");
    },
    extractOptions: function(ele) {
      var i, len, options, ref, row;
      options = {};
      ref = ele.find("._nest-option-row:not(.template)");
      for (i = 0, len = ref.length; i < len; i++) {
        row = ref[i];
        nest.addOption(options, $(row));
      }
      return options;
    },
    addOption: function(options, row) {
      var name, val;
      val = row.find("._nest-option-value").val();
      if (!((val != null) && val.length > 0)) {
        return;
      }
      name = row.find("._nest-option-name").val();
      if (options[name] != null) {
        return options[name].push(val);
      } else {
        return options[name] = [val];
      }
    },
    toggleOptionName: function(container, name, active) {
      var i, len, ref, results, sel;
      if (name === "show" || name === "hide") {
        return true;
      }
      ref = container.find("._nest-option-name");
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        sel = ref[i];
        if ($(sel).val() !== name) {
          $(sel).find("option[value=" + name + "]").attr("disabled", active);
        }
        results.push(decko.initSelect2($(sel)));
      }
      return results;
    },
    toNestSyntax: function(opts) {
      var name, str, values;
      str = [];
      for (name in opts) {
        values = opts[name];
        str.push(name + ": " + (values.join(', ')));
      }
      return str.join("; ");
    }
  });

}).call(this);

// nest_editor_name.js.coffee
(function() {
  var nestNameTimeout;

  nestNameTimeout = null;

  $(document).ready(function() {
    $('body').on('click', '._nest-field-toggle', function() {
      if ($(this).is(':checked')) {
        return nest.addPlus();
      } else {
        return nest.removePlus();
      }
    });
    $('body').on('input', 'input._nest-name', function(event) {
      nest.nameChanged();
      if (event.which !== 13) {
        if (nestNameTimeout) {
          clearTimeout(nestNameTimeout);
        }
        return nestNameTimeout = setTimeout((function() {
          return nest.updateNameRelatedTabs();
        }), 700);
      }
    });
    return $('body').on('keydown', 'input._nest-name', function(event) {
      if (event.which === 13) {
        if (nestNameTimeout) {
          clearTimeout(nestNameTimeout);
        }
        return nest.updateNameRelatedTabs();
      }
    });
  });

  $.extend(nest, {
    name: function() {
      return nest.evalFieldOption($('input._nest-name').val());
    },
    nameChanged: function() {
      var new_val;
      new_val = $("._nest-preview").val().replace(/^\{\{[^}|]*/, "{{" + nest.name());
      return nest.updatePreview(new_val);
    },
    evalFieldOption: function(name) {
      if (nest.isField()) {
        return "+" + name;
      } else {
        return name;
      }
    },
    isField: function() {
      return $('._nest-field-toggle').is(":checked");
    },
    addPlus: function() {
      var new_val;
      new_val = $("._nest-preview").val().replace(/^\{\{\+?/, "{{+");
      nest.updatePreview(new_val);
      return $(".input-group.hide-prefix").removeClass("hide-prefix").addClass("show-prefix");
    },
    removePlus: function() {
      var new_val;
      new_val = $("._nest-preview").val().replace(/^\{\{\+?/, "{{");
      nest.updatePreview(new_val);
      return $(".input-group.show-prefix").removeClass("show-prefix").addClass("hide-prefix");
    },
    rulesTabSlot: function() {
      return $("._nest-editor .tab-pane-rules > .card-slot");
    },
    contentTabSlot: function() {
      return $("._nest-editor .tab-pane-content > .card-slot");
    },
    emptyNameAlert: function(show) {
      if (show) {
        return $("._empty-nest-name-alert").removeClass("d-none");
      } else {
        return $("._empty-nest-name-alert:not(.d-none)").addClass("d-none");
      }
    },
    updateNameRelatedTabs: function() {
      nest.updateRulesTab();
      return nest.updateContentTab();
    },
    updateContentTab: function() {
      var $contentTab, url;
      $contentTab = nest.contentTabSlot();
      if ($contentTab.length > 0) {
        url = decko.path((nest.fullName()) + "?view=nest_content");
        return nest.updateNameDependentSlot($contentTab, url);
      }
    },
    updateRulesTab: function() {
      var $rulesTab, url;
      $rulesTab = nest.rulesTabSlot();
      url = decko.path((nest.setNameForRules()) + "?view=nest_rules");
      return nest.updateNameDependentSlot($rulesTab, url);
    },
    updateNameDependentSlot: function($slot, url) {
      var name;
      name = $("input._nest-name").val();
      if ((name != null) && name.length > 0) {
        nest.emptyNameAlert(false);
        return $slot.reloadSlot(url);
      } else {
        $slot.clearSlot();
        return nest.emptyNameAlert(true);
      }
    },
    fullName: function() {
      var input, nest_name;
      input = $('input._nest-name');
      nest_name = input.val();
      if (nest.isField() && input.attr("data-left-name")) {
        return (input.attr("data-left-name")) + "+" + nest_name;
      } else {
        return nest_name;
      }
    },
    setNameForRules: function() {
      var input, nest_name;
      input = $('input._nest-name');
      nest_name = input.val();
      if (nest.isField()) {
        if (input.attr("data-left-type")) {
          return (input.attr("data-left-type")) + "+" + nest_name + "+*type plus right";
        } else {
          return nest_name + "+*right";
        }
      } else {
        return nest_name + "+*self";
      }
    }
  });

}).call(this);

// link_editor.js.coffee
(function() {
  $(document).ready(function() {
    return $('body').on('click', 'button._link-apply', function() {
      return link.applyLink($(this).data("tinymce-id"), $(this).data("tm-snippet-start"), $(this).data("tm-snippet-size"));
    });
  });

  window.link || (window.link = {});

  $(document).ready(function() {
    $('body').on('click', '._link-field-toggle', function() {
      if ($(this).is(':checked')) {
        return link.addPlus();
      } else {
        return link.removePlus();
      }
    });
    $('body').on('input', 'input._link-target', function(event) {
      return link.targetChanged();
    });
    return $('body').on('input', 'input._link-title', function(event) {
      return link.titleChanged();
    });
  });

  $.extend(link, {
    openLinkEditor: function(tm) {
      var params;
      if (typeof params === "undefined" || params === null) {
        params = nest.editParams(tm, "[[", "]]");
      }
      return nest.openEditorForTm(tm, params, "link_editor", "modal_link_editor");
    },
    applyLink: function(tinymce_id, link_start, link_size) {
      return nest.applySnippet("link", tinymce_id, link_start, link_size);
    },
    target: function() {
      return link.evalFieldOption($('input._link-target').val());
    },
    title: function() {
      return $('input._link-title').val();
    },
    titleChanged: function() {
      var new_val;
      new_val = $("._link-preview").val().replace(/^\[\[[^\]]*/, "[[" + link.target() + "|" + link.title());
      return link.updatePreview(new_val);
    },
    targetChanged: function() {
      var new_val;
      new_val = $("._link-preview").val().replace(/^\[\[[^\]|]*/, "[[" + link.target());
      return link.updatePreview(new_val);
    },
    evalFieldOption: function(name) {
      if (link.isField()) {
        return "+" + name;
      } else {
        return name;
      }
    },
    isField: function() {
      return $('._link-field-toggle').is(":checked");
    },
    addPlus: function() {
      var new_val;
      new_val = $("._link-preview").val().replace(/^\[\[\+?/, "[[+");
      link.updatePreview(new_val);
      return $(".input-group.hide-prefix").removeClass("hide-prefix").addClass("show-prefix");
    },
    removePlus: function() {
      var new_val;
      new_val = $("._link-preview").val().replace(/^\[\[\+?/, "[[");
      link.updatePreview(new_val);
      return $(".input-group.show-prefix").removeClass("show-prefix").addClass("hide-prefix");
    },
    updatePreview: function(new_val) {
      if (new_val == null) {
        new_val = "[[" + (link.target()) + "|" + (link.title()) + "]]";
      }
      return $("._link-preview").val(new_val);
    }
  });

}).call(this);

// components.js.coffee
(function() {
  var submitAfterTyping;

  submitAfterTyping = null;

  $(window).ready(function() {
    $('body').on('show.bs.tab', 'a.load[data-toggle="tab"][data-url]', function(e) {
      var tab_id, url;
      tab_id = $(e.target).attr('href');
      url = $(e.target).data('url');
      $(e.target).removeClass('load');
      return $.ajax({
        url: url,
        type: 'GET',
        success: function(html) {
          $(tab_id).append(html);
          return decko.contentLoaded($(tab_id), $(this));
        }
      });
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
    $('body').on("change", "._submit-on-change", function(event) {
      $(event.target).closest('form').submit();
      return false;
    });
    $('body').on("change", "._edit-item", function(event) {
      var cb;
      cb = $(event.target);
      if (cb.is(":checked")) {
        cb.attr("name", "add_item");
      } else {
        cb.attr("name", "drop_item");
      }
      $(event.target).closest('form').submit();
      return false;
    });
    return $("body").on("click", "._popover_link", function(event) {
      return event.preventDefault();
    });
  });

}).call(this);

// follow.js.coffee
(function() {
  $(window).ready(function() {
    $('body').on('click', '.btn-item', function() {
      return $(this).find('i').html('hourglass_full');
    });
    $('body').on('mouseenter', '.btn-item-delete', function() {
      $(this).find('i').html('remove');
      return $(this).addClass("btn-danger").removeClass("btn-primary");
    });
    $('body').on('mouseleave', '.btn-item-delete', function() {
      $(this).find('i').html('check');
      return $(this).addClass("btn-primary").removeClass("btn-danger");
    });
    $('body').on('click', '.follow-updater', function() {
      return $(this).closest('form').find('#card_update_all_users').val('true');
    });
    return $('body').on('submit', '.edit-view.SELF-Xfollow_default .card-form', function() {
      var confirmer;
      confirmer = $(this).find('.confirm_update_all-view');
      if (confirmer.is(':hidden')) {
        $(this).find('.follow-updater').show();
        confirmer.show('blind');
        return false;
      }
    });
  });

}).call(this);

// card_menu.js.coffee
(function() {
  var detectMobileBrowser;

  decko.isTouchDevice = function() {
    if ('ontouchstart' in window || window.DocumentTouch && document instanceof DocumentTouch) {
      return true;
    } else {
      return detectMobileBrowser();
    }
  };

  detectMobileBrowser = function(userAgent) {
    userAgent = navigator.userAgent || navigator.vendor || window.opera;
    return /(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows ce|xda|xiino/i.test(userAgent) || /1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(userAgent.substr(0, 4));
  };

  decko.slotReady(function(slot) {
    if (decko.isTouchDevice()) {
      return slot.find('._show-on-hover').removeClass('_show-on-hover');
    }
  });

  $(window).ready(function() {
    $('body').on('show.bs.popover', '._card-menu-popover', function() {
      return $(this).closest(".card-menu._show-on-hover").removeClass("_show-on-hover").addClass("_show-on-hover-disabled");
    });
    return $('body').on('hide.bs.popover', '._card-menu-popover', function() {
      return $(this).closest(".card-menu._show-on-hover-disabled").removeClass("_show-on-hover-disabled").addClass("_show-on-hover");
    });
  });

}).call(this);

// slot_ready.js.coffee
(function() {
  decko.slotReady(function(slot) {
    slot.find('._disappear').delay(5000).animate({
      height: 0
    }, 1000, function() {
      return $(this).hide();
    });
    if (slot.hasClass("_refresh-timer")) {
      return setTimeout(function() {
        return slot.reloadSlot(slot.data("refresh-url"));
      }, 2000);
    }
  });

}).call(this);

// pointer_config.js.coffee
(function() {
  var permissionsContent, pointerContent;

  $.extend(decko.editorContentFunctionMap, {
    'select.pointer-select': function() {
      return pointerContent(this.val());
    },
    'select.pointer-multiselect': function() {
      return pointerContent(this.val());
    },
    '.pointer-radio-list': function() {
      return pointerContent(this.find('input:checked').val());
    },
    '.pointer-list-ul': function() {
      return pointerContent(this.find('input').map(function() {
        return $(this).val();
      }));
    },
    '.pointer-link-list-ul': function() {
      return decko.linkListContent(this.find('.input-group'));
    },
    '._nest-list-ul': function() {
      return decko.nestListContent(this.find('.input-group'));
    },
    '.pointer-checkbox-list': function() {
      return pointerContent(this.find('input:checked').map(function() {
        return $(this).val();
      }));
    },
    '.pointer-select-list': function() {
      return pointerContent(this.find('.pointer-select select').map(function() {
        return $(this).val();
      }));
    },
    '._pointer-filtered-list': function() {
      return pointerContent(this.find('._filtered-list-item').map(function() {
        return $(this).data('cardName');
      }));
    },
    '._pointer-list': function() {
      return pointerContent(this.find('._pointer-item').map(function() {
        return $(this).val();
      }));
    },
    '.perm-editor': function() {
      return permissionsContent(this);
    }
  });

  decko.editorInitFunctionMap['.pointer-list-editor'] = function() {
    this.sortable({
      handle: '.handle',
      cancel: ''
    });
    return decko.initPointerList(this.find('input'));
  };

  decko.editorInitFunctionMap['._pointer-filtered-list'] = function() {
    return this.sortable({
      handle: '._handle',
      cancel: ''
    });
  };

  $.extend(decko, {
    initPointerList: function(input) {
      return decko.initAutoCardPlete(input);
    },
    initAutoCardPlete: function(input) {
      var optionsCard, path;
      optionsCard = input.data('options-card');
      if (!optionsCard) {
        return;
      }
      path = optionsCard + '.json?view=name_match';
      return input.autocomplete({
        source: decko.slotPath(path)
      });
    },
    pointerContent: function(vals) {
      var list;
      list = $.map($.makeArray(vals), function(v) {
        if (v) {
          return '[[' + v + ']]';
        }
      });
      return $.makeArray(list).join("\n");
    },
    linkListContent: function(input_groups) {
      var list, vals;
      vals = input_groups.map(function() {
        var title, v;
        v = $(this).find('input._reference').val();
        title = $(this).find('input._title').val();
        if (title.length > 0) {
          v += "|" + title;
        }
        return v;
      });
      list = $.map($.makeArray(vals), function(v) {
        if (v) {
          return '[[' + v + ']]';
        }
      });
      return $.makeArray(list).join("\n");
    },
    nestListContent: function(input_groups) {
      var list, vals;
      vals = input_groups.map(function() {
        var options, v;
        v = $(this).find('input._reference').val();
        options = $(this).find('input._nest-options').val();
        if (options.length > 0) {
          v += "|" + options;
        }
        return v;
      });
      list = $.map($.makeArray(vals), function(v) {
        if (v) {
          return '{{' + v + '}}';
        }
      });
      return $.makeArray(list).join("\n");
    }
  });

  pointerContent = function(vals) {
    return decko.pointerContent(vals);
  };

  permissionsContent = function(ed) {
    var groups, indivs;
    if (ed.find('#inherit').is(':checked')) {
      return '_left';
    }
    groups = ed.find('.perm-group input:checked').map(function() {
      return $(this).val();
    });
    indivs = ed.find('.perm-indiv input').map(function() {
      return $(this).val();
    });
    return pointerContent($.makeArray(groups).concat($.makeArray(indivs)));
  };

}).call(this);

// pointer_list_editor.js.coffee
(function() {
  $(window).ready(function() {
    $('body').on('click', '._pointer-item-add', function(event) {
      decko.addPointerItem(this);
      return event.preventDefault();
    });
    $('body').on('keydown', '.pointer-item-text', function(event) {
      if (event.key === 'Enter') {
        decko.addPointerItem(this);
        return event.preventDefault();
      }
    });
    $('body').on('keyup', '.pointer-item-text', function(_event) {
      return decko.updateAddItemButton(this);
    });
    return $('body').on('click', '.pointer-item-delete', function() {
      var item, list;
      item = $(this).closest('li');
      list = item.closest('ul');
      if (list.find('.pointer-li').length > 1) {
        item.remove();
      } else {
        item.find('input').val('');
      }
      return decko.updateAddItemButton(list);
    });
  });

  decko.slotReady(function(slot) {
    return slot.find('.pointer-list-editor').each(function() {
      return decko.updateAddItemButton(this);
    });
  });

  $.extend(decko, {
    addPointerItem: function(el) {
      var newInput, slot;
      slot = $(el).slot();
      slot.trigger("slotDestroy");
      newInput = decko.nextPointerInput(decko.lastPointerItem(el));
      newInput.val('');
      slot.trigger("slotReady");
      decko.initializeEditors(slot);
      newInput.first().focus();
      decko.updateAddItemButton(el);
      return decko.initPointerList(newInput);
    },
    nextPointerInput: function(lastItem) {
      var all_empty, i, input, lastInputs, len, newItem;
      lastInputs = lastItem.find('input');
      all_empty = true;
      for (i = 0, len = lastInputs.length; i < len; i++) {
        input = lastInputs[i];
        all_empty = all_empty && $(input).val() === '';
      }
      if (all_empty) {
        return lastInputs;
      }
      newItem = lastItem.clone();
      lastItem.after(newItem);
      newItem.attr("data-index", parseInt(lastItem.attr("data-index") + 1));
      return newItem.find('input');
    },
    lastPointerItem: function(el) {
      return $(el).closest('.content-editor').find('.pointer-li:last');
    },
    updateAddItemButton: function(el) {
      var button, disabled;
      button = $(el).closest('.content-editor').find('._pointer-item-add');
      disabled = decko.lastPointerItem(el).find('input').val() === '';
      return button.prop('disabled', disabled);
    }
  });

}).call(this);

// filter.js.coffee
(function() {
  decko.filter = function(el) {
    var closest_widget;
    closest_widget = $(el).closest("._filter-widget");
    this.widget = closest_widget.length ? closest_widget : $(el).closest("._filtered-content").find("._filter-widget");
    this.form = this.widget.find("._filter-form");
    this.quickFilter = this.widget.find("._quick-filter");
    this.activeContainer = this.widget.find("._filter-container");
    this.dropdown = this.widget.find("._add-filter-dropdown");
    this.dropdownItems = this.widget.find("._filter-category-select");
    this.showWithStatus = function(status) {
      var f;
      f = this;
      return $.each(this.dropdownItems, function() {
        var item;
        item = $(this);
        if (item.data(status)) {
          return f.activate(item.data("category"));
        }
      });
    };
    this.reset = function() {
      return this.restrict(this.form.find("._reset-filter").data("reset"));
    };
    this.clear = function() {
      this.dropdownItems.show();
      return this.activeContainer.find(".input-group").remove();
    };
    this.activate = function(category, value) {
      this.activateField(category, value);
      return this.hideOption(category);
    };
    this.showOption = function(category) {
      this.dropdown.show();
      return this.option(category).show();
    };
    this.hideOption = function(category) {
      this.option(category).hide();
      if (this.dropdownItems.length <= this.activeFields().length) {
        return this.dropdown.hide();
      }
    };
    this.activeFields = function() {
      return this.activeContainer.find("._filter-input");
    };
    this.option = function(category) {
      return this.dropdownItems.filter("[data-category='" + category + "']");
    };
    this.findPrototype = function(category) {
      return this.widget.find("._filter-input-field-prototypes ._filter-input-" + category);
    };
    this.activateField = function(category, value) {
      var field;
      field = this.findPrototype(category).clone();
      this.fieldValue(field, value);
      this.dropdown.before(field);
      this.initField(field);
      return field.find("input, select").first().focus();
    };
    this.fieldValue = function(field, value) {
      if (typeof value === "object" && !Array.isArray(value)) {
        return this.compoundFieldValue(field, value);
      } else {
        return this.simpleFieldValue(field, value);
      }
    };
    this.simpleFieldValue = function(field, value) {
      var input;
      input = field.find("input, select");
      if (typeof value !== 'undefined') {
        return input.val(value);
      }
    };
    this.compoundFieldValue = function(field, vals) {
      var input, key, results;
      results = [];
      for (key in vals) {
        input = field.find("#filter_value_" + key);
        results.push(input.val(vals[key]));
      }
      return results;
    };
    this.removeField = function(category) {
      this.activeField(category).remove();
      return this.showOption(category);
    };
    this.initField = function(field) {
      this.initSelectField(field);
      return decko.initAutoCardPlete(field.find("input"));
    };
    this.initSelectField = function(field) {
      return field.find("select").select2({
        containerCssClass: ":all:",
        width: "auto",
        dropdownAutoWidth: "true"
      });
    };
    this.activeField = function(category) {
      return this.activeContainer.find("._filter-input-" + category);
    };
    this.isActive = function(category) {
      return this.activeField(category).length;
    };
    this.restrict = function(data) {
      var key;
      this.clear();
      for (key in data) {
        this.activateField(key, data[key]);
      }
      return this.update();
    };
    this.addRestrictions = function(hash) {
      var category;
      for (category in hash) {
        this.removeField(category);
        this.activate(category, hash[category]);
      }
      return this.update();
    };
    this.removeRestrictions = function(hash) {
      var category;
      for (category in hash) {
        this.removeField(category);
      }
      return this.update();
    };
    this.setInputVal = function(field, value) {
      var select;
      select = field.find("select");
      if (select.length) {
        return this.setSelect2Val(select, value);
      } else {
        return this.setTextInputVal(field.find("input"), value);
      }
    };
    this.setSelect2Val = function(select, value) {
      if (select.attr("multiple") && !Array.isArray(value)) {
        value = [value];
      }
      return select.select2("val", value);
    };
    this.setTextInputVal = function(input, value) {
      input.val(value);
      return this.update();
    };
    this.updateLastVals = function() {
      return this.activeFields().find("input, select").each(function() {
        return $(this).data("lastVal", $(this).val());
      });
    };
    this.updateUrlBar = function() {
      if (this.widget.closest('._noFilterUrlUpdates')[0]) {
        return;
      }
      return window.history.pushState("filter", "filter", '?' + this.form.serialize());
    };
    this.update = function() {
      this.updateLastVals();
      this.updateQuickLinks();
      this.form.submit();
      return this.updateUrlBar();
    };
    this.updateQuickLinks = function() {
      var links, widget;
      widget = this;
      links = this.quickFilter.find("._filter-link");
      links.addClass("active");
      return links.each(function() {
        var key, link, opts, results;
        link = $(this);
        opts = link.data("filter");
        results = [];
        for (key in opts) {
          results.push(widget.deactivateQuickLink(link, key, opts[key]));
        }
        return results;
      });
    };
    this.deactivateQuickLink = function(link, key, value) {
      var sel;
      sel = "._filter-input-" + key;
      return $.map([this.form.find(sel + " input, " + sel + " select").val()], function(arr) {
        arr = [arr].flat();
        if ($.inArray(value, arr) > -1) {
          return link.removeClass("active");
        }
      });
    };
    this.updateIfChanged = function() {
      if (this.changedSinceLastVal()) {
        return this.update();
      }
    };
    this.updateIfPresent = function(category) {
      var val;
      val = this.activeField(category).find("input, select").val();
      if (val && val.length > 0) {
        return this.update();
      }
    };
    this.changedSinceLastVal = function() {
      var changed;
      changed = false;
      this.activeFields().find("input, select").each(function() {
        if ($(this).val() !== $(this).data("lastVal")) {
          return changed = true;
        }
      });
      return changed;
    };
    return this;
  };

}).call(this);

// filter_links.js.coffee
(function() {
  decko.slotReady(function(slot) {
    return slot.find("._filter-widget").each(function() {
      var filter;
      if (slot[0] === $(this).slot()[0]) {
        filter = new decko.filter(this);
        filter.showWithStatus("active");
        filter.updateLastVals();
        return filter.updateQuickLinks();
      }
    });
  });

  $(window).ready(function() {
    var filterFor, filterableData, inactiveQuickfilter, keyupTimeout, onchangers, targetFilter, weirdoSelect2FilterBreaker;
    filterFor = function(el) {
      return new decko.filter(el);
    };
    weirdoSelect2FilterBreaker = function(el) {
      return $(el).hasClass("select2-search__field");
    };
    filterableData = function(filterable) {
      var f;
      f = $(filterable);
      return f.data("filter") || f.find("._filterable").data("filter");
    };
    targetFilter = function(filterable) {
      var selector;
      selector = $(filterable).closest("._filtering").data("filter-selector");
      return filterFor(selector || this);
    };
    $("body").on("click", "._filter-category-select", function(e) {
      var category, f;
      e.preventDefault();
      f = filterFor(this);
      category = $(this).data("category");
      f.activate(category);
      return f.updateIfPresent(category);
    });
    onchangers = "._filter-input input:not(.simple-text), ._filter-input select, ._filter-sort";
    $("body").on("change", onchangers, function() {
      if (weirdoSelect2FilterBreaker(this)) {
        return;
      }
      return filterFor(this).update();
    });
    keyupTimeout = null;
    $("body").on("keyup", "._filter-input input.simple-text", function() {
      var filter;
      clearTimeout(keyupTimeout);
      filter = filterFor(this);
      return keyupTimeout = setTimeout((function() {
        return filter.updateIfChanged();
      }), 333);
    });
    $("body").on("click", "._delete-filter-input", function() {
      var filter;
      filter = filterFor(this);
      filter.removeField($(this).closest("._filter-input").data("category"));
      return filter.update();
    });
    $('body').on('click', '._reset-filter', function() {
      var f;
      f = filterFor(this);
      f.reset();
      return f.update();
    });
    $('body').on('click', '._filtering ._filterable', function(e) {
      var f;
      f = targetFilter(this);
      if (f.widget.length) {
        f.restrict(filterableData(this));
        e.preventDefault();
        return e.stopPropagation();
      }
    });
    $('body').on('click', '._filter-link', function(e) {
      var f, filter_data, link;
      f = filterFor(this);
      link = $(this);
      filter_data = link.data("filter");
      if (inactiveQuickfilter(link)) {
        f.removeRestrictions(filter_data);
      } else {
        f.addRestrictions(filter_data);
      }
      e.preventDefault();
      return e.stopPropagation();
    });
    return inactiveQuickfilter = function(link) {
      return !link.hasClass("active") && link.closest(".quick-filter").length > 0;
    };
  });

}).call(this);

// filter_items.js.coffee
(function() {
  var addSelectedButton, addSelectedButtonUrl, arrayFromField, deselectAllLink, filterBox, newFilteredListContent, prefilteredData, prefilteredIds, prefilteredNames, selectFilteredItem, selectedBin, selectedData, selectedIds, selectedNames, trackSelectedIds, updateAfterSelection, updateSelectedCount, updateSelectedSectionVisibility, updateUnselectedCount;

  $(window).ready(function() {
    $("body").on("click", "._filter-items ._add-selected", function() {
      var btn, content;
      btn = $(this);
      content = newFilteredListContent(btn);
      return btn.attr("href", addSelectedButtonUrl(btn, content));
    });
    $("body").on("click", "._select-all", function() {
      filterBox($(this)).find("._unselected input._checkbox-list-checkbox").each(function() {
        return selectFilteredItem($(this));
      });
      $(this).prop("checked", false);
      return updateAfterSelection($(this));
    });
    $("body").on("click", "._deselect-all", function() {
      filterBox($(this)).find("._selected input._checkbox-list-checkbox").each(function() {
        return $(this).slot().remove();
      });
      $(this).prop("checked", true);
      return updateAfterSelection($(this));
    });
    $("body").on("click", "._filter-items ._unselected input._checkbox-list-checkbox", function() {
      selectFilteredItem($(this));
      return updateAfterSelection($(this));
    });
    $("body").on("click", "._filter-items ._selected input._checkbox-list-checkbox", function() {
      var bin;
      bin = selectedBin($(this));
      $(this).slot().remove();
      return updateAfterSelection(bin);
    });
    return $('body').on('click', '._filtered-list-item-delete', function() {
      return $(this).closest('li').remove();
    });
  });

  newFilteredListContent = function(el) {
    return $.map(prefilteredIds(el).concat(selectedIds(el)), function(id) {
      return "~" + id;
    }).join("\n");
  };

  addSelectedButtonUrl = function(btn, content) {
    var card_args, path_base, query, view;
    view = btn.slot().data("slot")["view"];
    card_args = {
      content: content,
      type: "Pointer"
    };
    query = {
      assign: true,
      view: view,
      card: card_args
    };
    path_base = btn.attr("href") + "&" + $.param(query);
    return decko.slotPath(path_base, btn.slot());
  };

  updateAfterSelection = function(el) {
    var f;
    trackSelectedIds(el);
    f = new decko.filter(filterBox(el).find('._filter-widget'));
    f.update();
    updateSelectedCount(el);
    return updateUnselectedCount(el);
  };

  updateSelectedCount = function(el) {
    var count;
    count = selectedBin(el).children().length;
    filterBox(el).find("._selected-items").html(count);
    deselectAllLink(el).attr("disabled", count === 0);
    if (count > 0) {
      addSelectedButton(el).removeClass("disabled");
    } else {
      addSelectedButton(el).addClass("disabled");
    }
    return updateSelectedSectionVisibility(el, count > 0);
  };

  updateSelectedSectionVisibility = function(el, items_present) {
    var box, help_text, selected_items;
    box = filterBox(el);
    selected_items = box.find("._selected-item-list");
    help_text = box.find("._filter-help");
    if (items_present) {
      selected_items.show();
      return help_text.hide();
    } else {
      selected_items.hide();
      return help_text.show();
    }
  };

  updateUnselectedCount = function(el) {
    var box, count;
    box = filterBox(el);
    count = box.find("._search-checkbox-list").children().length;
    box.find("._unselected-items").html(count);
    return box.find("._select-all").attr("disabled", count > 0);
  };

  selectFilteredItem = function(checkbox) {
    checkbox.prop("checked", true);
    return selectedBin(checkbox).append(checkbox.slot());
  };

  selectedBin = function(el) {
    return filterBox(el).find("._selected-bin");
  };

  filterBox = function(el) {
    return el.closest("._filter-items");
  };

  addSelectedButton = function(el) {
    return filterBox(el).find("._add-selected");
  };

  deselectAllLink = function(el) {
    return filterBox(el).find("._deselect-all");
  };

  selectedIds = function(el) {
    return selectedData(el, "cardId");
  };

  prefilteredIds = function(el) {
    return prefilteredData(el, "cardId");
  };

  prefilteredNames = function(el) {
    return prefilteredData(el, "cardName");
  };

  prefilteredData = function(el, field) {
    var btn, selector;
    btn = addSelectedButton(el);
    selector = btn.data("itemSelector");
    return arrayFromField(btn.slot().find(selector), field);
  };

  selectedNames = function(el) {
    return selectedData(el, "cardName");
  };

  selectedData = function(el, field) {
    return arrayFromField(selectedBin(el).children(), field);
  };

  arrayFromField = function(rows, field) {
    return rows.map(function() {
      return $(this).data(field);
    }).toArray();
  };

  trackSelectedIds = function(el) {
    var box, ids;
    ids = prefilteredIds(el).concat(selectedIds(el));
    box = filterBox(el);
    return box.find("._not-ids").val(ids.toString());
  };

}).call(this);

// selectable_filtered_content.js.coffee
(function() {
  $(window).ready(function() {
    return $("body").on("click", "._selectable-filtered-content .bar-body", function(e) {
      var container, input, item, name;
      item = $(this);
      name = item.slot().data("card-name");
      container = item.closest("._selectable-filtered-content");
      input = $(container.data("input-selector"));
      input.val(name);
      item.closest('.modal').modal('hide');
      e.preventDefault();
      return e.stopPropagation();
    });
  });

}).call(this);
