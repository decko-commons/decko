$(window).ready ->

  $('body').on 'show.bs.tab', 'a', (e) ->
    link = $(this)
    return if link.closest(".tab-content").length > 0

    tabname = $(this).data "tabName"
    window.history.pushState("tab", "", "?tab=" + tabname)

  $('body').on 'show.bs.tab', 'a.load[data-bs-toggle="tab"][data-url]', (e) ->
    targ = $(e.target)
    tab_id = targ.attr "href"
    url    = targ.data "url"
    targ.removeClass "load"
    tab_pane = $(tab_id)
    tab_content = tab_pane.closest(".tab-panel").children ".tab-content"
    tab_content.startLoading true

    $.ajax
      url: url
      success: (html) ->
        tab_pane.append(html)
        decko.contentLoaded tab_pane, $(this)
      complete: ()->
        tab_content.stopLoading true
