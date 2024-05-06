$(window).ready ->
  $('body').on 'show.bs.tab', 'a.load[data-bs-toggle="tab"][data-url]', (e) ->
    tab_id = $(e.target).attr('href')
    url    = $(e.target).data('url')
    tabname = $(this).data "tabName"
    $(e.target).removeClass('load')
    $.ajax
      url: url
      success: (html) ->
        $(tab_id).append(html)
        window.history.pushState("tab", "", "?tab=" + tabname)
        decko.contentLoaded $(tab_id), $(this)
