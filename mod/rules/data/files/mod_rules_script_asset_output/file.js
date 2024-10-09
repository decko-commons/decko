// rules.js.coffee
(function() {
  decko.slot.ready(function(slot) {
    return slot.find('._setting-filter').each(function() {
      return decko.filterRulesByCategory($(this).closest(".card-slot"), $(this).find('input._setting-category:checked').attr("id"));
    });
  });

  $.extend(decko, {
    filterRulesByCategory: function(container, category) {
      return $(container).find('._setting-list ._setting-group').each(function(_i) {
        var $list, hiddenCount, items;
        $list = $(this);
        items = $list.find('._rule-item');
        hiddenCount = 0;
        items.each(function() {
          var $item, wrapper;
          $item = $(this);
          wrapper = $item.parent().is("li") ? $item.parent() : $item;
          if ($item.hasClass("_category-" + category)) {
            return wrapper.show();
          } else {
            wrapper.hide();
            return hiddenCount += 1;
          }
        });
        if (hiddenCount === items.length) {
          return $list.hide();
        } else {
          $list.show();
          return $list.find('._count').html(items.length - hiddenCount);
        }
      });
    }
  });

  $(window).ready(function() {
    $('body').on('click', '.perm-vals input', function() {
      return $(this).slot().find('#inherit').attr('checked', false);
    });
    $('body').on('click', '.perm-editor #inherit', function() {
      var slot;
      slot = $(this).slot();
      slot.find('.perm-group input:checked').attr('checked', false);
      return slot.find('.perm-indiv input').val('');
    });
    $('body').on('click', '._rule-submit-button', function() {
      var checked, f;
      f = $(this).closest('form');
      checked = f.find('._set-editor input:checked');
      if (checked.val()) {
        if (checked.attr('warning')) {
          return confirm(checked.attr('warning'));
        } else {
          return true;
        }
      } else {
        f.find('._set-editor').addClass('warning');
        $(this).notify('To what Set does this Rule apply?');
        return false;
      }
    });
    return $('body').on('click', 'input._setting-category', function() {
      var category;
      category = $(this).attr("id");
      return decko.filterRulesByCategory($(this).closest('.card-slot'), category);
    });
  });

}).call(this);
