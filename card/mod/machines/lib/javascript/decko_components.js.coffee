decko.slotReady (slot) ->
  $('[data-toggle="popover"]').popover(html: true)

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
        $(tab_id).triggerSlotReady()

  $('body').on "select2:select", "._submit-on-select", (event) ->
    $(event.target).closest('form').submit()

  $('body').on "input", "._submit-after-typing", (event) ->
    form = $(event.target).closest('form')
    form.slot().find(".autosubmit-success-notification").remove()
    clearTimeout(submitAfterTyping) if submitAfterTyping
    submitAfterTyping = setTimeout ->
        $(event.target).closest('form').submit()
      , 1000

  $('body').on "keydown", "._submit-after-typing", (event) ->
    if event.which == 13
      clearTimeout(submitAfterTyping) if submitAfterTyping
      $(event.target).closest('form').submit()
      false




