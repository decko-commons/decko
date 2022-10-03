// rules.js.coffee
(function() {
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
    return $('body').on('click', '._rule-submit-button', function() {
      var checked, f;
      f = $(this).closest('form');
      checked = f.find('.set-editor input:checked');
      if (checked.val()) {
        if (checked.attr('warning')) {
          return confirm(checked.attr('warning'));
        } else {
          return true;
        }
      } else {
        f.find('.set-editor').addClass('warning');
        $(this).notify('To what Set does this Rule apply?');
        return false;
      }
    });
  });

}).call(this);
