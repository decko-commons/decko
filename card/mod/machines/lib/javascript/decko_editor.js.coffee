$.extend decko,
  editorContentFunctionMap: {}

  editorInitFunctionMap: {
    'textarea': -> $(this).autosize()
    '.file-upload': -> decko.upload_file(this)
    '.etherpad-textarea': ->
      $(this).closest('form')
      .find('.edit-submit-button')
      .attr('class', 'etherpad-submit-button')
  }

  addEditor: (selector, init, get_content) ->
    decko.editorContentFunctionMap[selector] = get_content
    decko.editorInitFunctionMap[selector] = init

jQuery.fn.extend {
  setContentFieldsFromMap: (map) ->
    map = decko.editorContentFunctionMap unless map?
    this_form = $(this)
    $.each map, (selector, fn) ->
      this_form.setContentFields(selector, fn)
  setContentFields: (selector, fn) ->
    $.each @find(selector), ->
      $(this).setContentField(fn)
  setContentField: (fn) ->
    field = @closest('.card-editor').find('.d0-card-content')
    init_val = field.val() # tinymce-jquery overrides val();
    # that's why we're not using it.
    new_val = fn.call this
    field.val new_val
    field.change() if init_val != new_val
}

doubleClickActiveMap = {off: false, on: true, signed_in: decko.currentUserId}

doubleClickActive = () ->
  doubleClickActiveMap[decko.doubleClick]
  # else alert "illegal configuration: " + decko.doubleClick

doubleClickApplies = (el) ->
  return false if ['.nodblclick', '.d0-card-header', '.card-editor'].some (klass) ->
    el.closest(klass)[0]
    # double click inactive inside header, editor, or tag with "nodblclick" class
  slot = el.slot()
  return false if slot.find('.card-editor')[0]
  # false if there is a card-editor open inside slot
  slot.data 'cardId'



triggerDoubleClickEditingOn = (el)->
  slot = el.slot()
  slot.addClass 'slotter'
  slot.attr 'href', decko.path('~' + slot.data('cardId') + '?view=edit')
  $.rails.handleRemote slot

$(window).ready ->
  if doubleClickActive()
    $('body').on 'dblclick', 'div', (_event) ->
      if doubleClickApplies $(this)
        triggerDoubleClickEditingOn $(this)
      false # don't propagate up to next slot



