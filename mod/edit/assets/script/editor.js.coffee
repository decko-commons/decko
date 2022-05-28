decko.editors.init["textarea"] = -> $(this).autosize()

$.extend decko,
  initializeEditors: (range, map) ->
    map = decko.editors.init unless map?
    $.each map, (selector, fn) ->
      $.each range.find(selector), ->
        fn.call $(this)

jQuery.fn.extend
  setContentFieldsFromMap: (map) ->
    map = decko.editors.content unless map?
    this_form = $(this)
    $.each map, (selector, fn) ->
      this_form.setContentFields(selector, fn)
  setContentFields: (selector, fn) ->
    $.each @find(selector), ->
      $(this).setContentField(fn)
  contentField: ->
    @closest('.card-editor').find '.d0-card-content'
  setContentField: (fn) ->
    field = @contentField()
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




