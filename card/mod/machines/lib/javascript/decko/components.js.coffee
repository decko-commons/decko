decko.slotReady (slot) ->
  $('[data-toggle="popover"]').popover(html: true)

  $('.colorpicker-component').colorpicker()

submitAfterTyping = null

$(window).ready ->
  $('body').on 'show.bs.tab', 'a.load[data-toggle="tab"][data-url]', (e) ->
    tab_id = $(e.target).attr('href')
    url    = $(e.target).data('url')
    $(e.target).removeClass('load')
    $.ajax
      url: url
      type: 'GET'
      success: (html) ->
        $(tab_id).append(html)
        decko.contentLoaded($(tab_id), $(this))

  $('body').on "input", "._submit-after-typing", (event) ->
    form = $(event.target).closest('form')
    form.slot().find(".autosubmit-success-notification").remove()
    clearTimeout(submitAfterTyping) if submitAfterTyping
    submitAfterTyping = setTimeout ->
        $(event.target).closest('form').submit()
        submitAfterTyping = null
      , 1000

  $('body').on "keydown", "._submit-after-typing", (event) ->
    if event.which == 13
      clearTimeout(submitAfterTyping) if submitAfterTyping
      submitAfterTyping = null
      $(event.target).closest('form').submit()
      false

  $('body').on "change", "._submit-on-change", (event) ->
    $(event.target).closest('form').submit()
    false

  $('body').on "change", "._edit-item", (event) ->
    cb = $(event.target)
    if cb.is(":checked")
      cb.attr("name", "add_item")
    else
      cb.attr("name", "drop_item")

    $(event.target).closest('form').submit()
    false



