submitAfterTyping = null

$(window).ready ->
  $('body').on "change", "._submit-on-change", (event) ->
    $(event.target).closest('form').submit()
    false

  # TODO: consider refactoring so that all of this is handled by _submit-on-change

  # submit form if user stops typing for a second
  $('body').on "input", "._submit-after-typing", (event) ->
    form = $(event.target).closest('form')
    form.slot().find(".autosubmit-success-notification").remove()
    clearTimeout(submitAfterTyping) if submitAfterTyping
    submitAfterTyping = setTimeout ->
        $(event.target).closest('form').submit()
        submitAfterTyping = null
      , 1000

  # if "enter/return" is pressed, submit right away
  $('body').on "keydown", "._submit-after-typing", (event) ->
    if event.which == 13 # enter/return
      clearTimeout(submitAfterTyping) if submitAfterTyping
      submitAfterTyping = null
      $(event.target).closest('form').submit()
      false

  $('body').on "change", "._edit-item", (event) ->
    cb = $(event.target)
    cb.attr "name", (cb.is(":checked") && "add_item" || "drop_item")
    $(event.target).closest('form').submit()
    false
