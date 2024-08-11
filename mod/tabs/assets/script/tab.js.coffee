$(window).ready ->
  $('body').on 'show.bs.tab', 'a.load[data-bs-toggle="tab"][data-url]', (e) ->
    targ = $(e.target)
    tab_id = targ.attr "href"
    url    = targ.data "url"
    tabname = $(this).data "tabName"
    targ.removeClass "load"
    tab_content = $(tab_id)
    # tab_content.slotReloading()

    $.ajax
      url: url
      success: (html) ->
        tab_content.append(html)
        window.history.pushState("tab", "", "?tab=" + tabname)
        decko.contentLoaded tab_content, $(this)
#      complete: ()->
#        tab_content.slotLoadingComplete()
