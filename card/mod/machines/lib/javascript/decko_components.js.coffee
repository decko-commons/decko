decko.slotReady (slot) ->
  $('[data-toggle="popover"]').popover(html: true)

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



