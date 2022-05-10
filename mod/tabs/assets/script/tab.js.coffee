$(window).ready ->
  $('body').on 'show.bs.tab', 'a.load[data-bs-toggle="tab"][data-url]', (e) ->
    tab_id = $(e.target).attr('href')
    url    = $(e.target).data('url')
    $(e.target).removeClass('load')
    $.ajax
      url: url
      success: (html) ->
        $(tab_id).append(html)
        decko.contentLoaded($(tab_id), $(this))