decko.slot.ready (slot)->
  slot.find('.modal.fade').on "loaded.bs.modal", ->
    $(this).trigger('slot.ready')

  slot.find('[data-toggle=\'modal\']').off("click").on "click", (e) ->
    e.preventDefault()
    e.stopPropagation()
    $_this = $(this)
    href = $_this.attr('href')
    modal_selector = $_this.data('target')
    $(modal_selector).modal('show')
    $.ajax
      url: href
      type: 'GET',
      success: (html) ->
        $(modal_selector + ' .modal-content').html html
        $(modal_selector).trigger "loaded.bs.modal"
      error: (jqXHR, _textStatus) ->
        $(modal_selector + ' .modal-content').html jqXHR.responseText
        $(modal_selector).trigger "loaded.bs.modal"
    false
