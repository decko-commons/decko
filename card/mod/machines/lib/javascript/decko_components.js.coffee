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




