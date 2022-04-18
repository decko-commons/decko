$(window).ready ->
  $('body').on 'click', '.btn-item', ->
    $(this).find('i').html('hourglass_full')

  $('body').on 'mouseenter', '.btn-item-delete', ->
    $(this).find('i').html('remove')
    $(this).addClass("btn-danger").removeClass("btn-primary")

  $('body').on 'mouseleave', '.btn-item-delete', ->
    $(this).find('i').html('check')
    $(this).addClass("btn-primary").removeClass("btn-danger")

  $('body').on 'submit', '.edit-view.SELF-Xfollow_default .card-form', ->
    confirmer = $(this).find '.confirm_update_all-view'
    if confirmer.is ':hidden'
      $(this).find('.follow-updater').show()

      confirmer.show 'blind'
      false
