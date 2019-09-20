$.extend decko,
  initializeEditors: (range, map) ->
    map = decko.editorInitFunctionMap unless map?
    $.each map, (selector, fn) ->
      $.each range.find(selector), ->
        fn.call $(this)

  editorContentFunctionMap: {}

  editorInitFunctionMap:
    'textarea': -> $(this).autosize()
    '.file-upload': -> decko.upload_file(this)
    '.etherpad-textarea': ->
      $(this).closest('form')
      .find('.edit-submit-button')
      .attr('class', 'etherpad-submit-button')

  addEditor: (selector, init, get_content) ->
    decko.editorContentFunctionMap[selector] = get_content
    decko.editorInitFunctionMap[selector] = init

jQuery.fn.extend
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

$(window).ready ->
  # decko.initializeEditors $('body > :not(.modal)')
  setTimeout (-> decko.initializeEditors $('body > :not(.modal)')), 10
  # dislike the timeout, but without this forms with multiple TinyMCE editors
  # were failing to load properly
  # I couldn't reproduce that problem described above -pk

  $('body').on 'submit', '.card-form', ->
    $(this).setContentFieldsFromMap()
    $(this).find('.d0-card-content').attr('no-autosave','true')
    true

setInterval (-> $('.card-form').setContentFieldsFromMap()), 20000




