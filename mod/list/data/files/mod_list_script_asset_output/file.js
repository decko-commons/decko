// pointer_config.js.coffee
(function() {
  var permissionsContent, pointerContent;

  $.extend(decko.editors.content, {
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
    '._filtered-list': function() {
      return pointerContent(this.find('._filtered-list-item').map(function() {
        return $(this).data('cardName');
      }));
    },
    '._pointer-list': function() {
      return pointerContent(this.find('._pointer-item').map(function() {
        return $(this).val();
      }));
    },
    '._click-select-editor': function() {
      return pointerContent(this.find('._select-item.selected').map(function() {
        return $($(this).find('[data-card-name]')[0]).data('cardName');
      }));
    },
    '._click-multiselect-editor': function() {
      return pointerContent(this.find('._select-item.selected').map(function() {
        return $($(this).find('[data-card-name]')[0]).data('cardName');
      }));
    },
    '.perm-editor': function() {
      return permissionsContent(this);
    }
  });

  $.extend(decko.editors.init, {
    ".pointer-list-editor": function() {
      this.sortable({
        handle: '.handle',
        cancel: ''
      });
      return decko.initPointerList(this.find('input'));
    },
    "._filtered-list": function() {
      return this.sortable({
        handle: '._handle',
        cancel: ''
      });
    }
  });

  $.extend(decko, {
    initPointerList: function(input) {
      return decko.initAutoCardPlete(input);
    },
    pointerContent: function(vals) {
      return $.makeArray(vals).join("\n");
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

  decko.slot.ready(function(slot) {
    return slot.find('.pointer-list-editor').each(function() {
      return decko.updateAddItemButton(this);
    });
  });

  $.extend(decko, {
    addPointerItem: function(el) {
      var newInput, slot;
      slot = $(el).slot();
      slot.trigger("decko.slot.destroy");
      newInput = decko.nextPointerInput(decko.lastPointerItem(el));
      newInput.val('');
      slot.trigger("decko.slot.ready");
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
      newItem.trigger("decko.item.added");
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
