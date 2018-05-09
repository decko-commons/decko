decko.addEditor(
  '.date-editor',
  ->
    decko.initDatepicker($(this))
  ->
    @val()
)

$.extend decko,
  setDatepickerConfig: (string) ->
    setter = ->
      try
        $.parseJSON string
      catch
        {}
    decko.datepickerConfig = setter()

  configDatepicker: () ->
    conf = { format: "YY-MM-DD" }
    hard_conf = {}
    user_conf = if decko.datepickerConfig? then decko.datepickerConfig else {}
    $.extend conf, user_conf, hard_conf
    conf

  initDatepicker: (input) ->
    input.datetimepicker(decko.configDatepicker())
