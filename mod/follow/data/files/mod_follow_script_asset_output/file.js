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
