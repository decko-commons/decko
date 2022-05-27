jQuery.fn.extend
  autosave: ->
    slot = @slot()
    return if @attr 'no-autosave'
    multi = @closest '.form-group'
    if multi[0]
      return unless id = multi.data 'cardId'
      reportee = ': ' + multi.data 'cardName'
    else
      id = slot.data 'cardId'
      reportee = ''

    return unless id

    # might be better to put this href base in the html
    submit_url = decko.path 'update/~' + id
    form_data = $('#edit_card_'+id).serializeArray().reduce( ((obj, item) ->
      obj[item.name] = item.value
      return obj
    ), { 'draft' : 'true', 'success[view]' : 'blank'});
    $.ajax submit_url, {
      data : form_data,
      type : 'POST'
    }
    ##{ 'card[content]' : @val() },

$(window).ready ->
  $('body').on 'change', '.autosave .d0-card-content', ->
    content_field = $(this)
    setTimeout ( -> content_field.autosave() ), 500
