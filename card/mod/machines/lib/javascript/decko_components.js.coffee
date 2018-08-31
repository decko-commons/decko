decko.slotReady (slot) ->

$(window).ready ->
  $('body').on 'show.bs.tab', 'a.load[data-toggle="tab"][data-url]', (e) ->
    tab_id = $(e.target).attr('href')
    url    = $(e.target).data('url')
    $(e.target).removeClass('load')
    $(tab_id).load(url)

