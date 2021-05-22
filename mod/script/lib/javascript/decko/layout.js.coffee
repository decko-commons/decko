wrapDeckoLayout = ->
  $footer  = $('body > footer').first()
  $('body > article, body > aside').wrapAll("<div class='#{containerClass()}'/>")
  $('body > div > article, body > div > aside')
    .wrapAll('<div class="row row-offcanvas">')
  if $footer
    $('body').append $footer

wrapSidebarToggle = (toggle, flex) ->
  "<div class='container'><div class='row #{flex}'>#{toggle}</div></div>"

containerClass = ->
  if $('body').hasClass('fluid') then "container-fluid" else "container"

toggleButton = (side) ->
  icon_dir = if side == 'left' then 'right' else 'left'
  "<button class='offcanvas-toggle btn btn-secondary "+
    "d-sm-none' data-toggle='offcanvas-#{side}'>" +
    "<i class='material-icons'>chevron_#{icon_dir}</i></button>"

sidebarToggle = (side) ->
  if side == "both"
    wrapSidebarToggle(toggleButton("left") + toggleButton("right"), "flex-row justify-content-between")
  else if side == "left"
    wrapSidebarToggle(toggleButton("left"), "flex-row")
  else
    wrapSidebarToggle(toggleButton("right"), "flex-row-reverse")

singleSidebar = (side) ->
  $article = $('body > article').first()
  $aside   = $('body > aside').first()
  $article.addClass("col-xs-12 col-sm-9")
  $aside.addClass(
    "col-xs-6 col-sm-3 sidebar-offcanvas sidebar-offcanvas-#{side}"
  )
  if side == 'left'
    $('body').append($aside).append($article)
  else
    $('body').append($article).append($aside)
  wrapDeckoLayout()
  $article.prepend(sidebarToggle(side))

doubleSidebar = ->
  $article    = $('body > article').first()
  $asideLeft  = $('body > aside').first()
  $asideRight = $($('body > aside')[1])
  $article.addClass("col-xs-12 col-sm-6")
  sideClass = "col-xs-6 col-sm-3 sidebar-offcanvas"
  $asideLeft.addClass("#{sideClass} sidebar-offcanvas-left")
  $asideRight.addClass("#{sideClass} sidebar-offcanvas-right")
  $('body').append($asideLeft).append($article).append($asideRight)
  wrapDeckoLayout()
  toggles = sidebarToggle('both')
  $article.prepend(toggles)

$.fn.extend toggleText: (a, b) ->
  @text(if @text() == b then a else b)

  this
$(window).ready ->
  switch
    when $('body').hasClass('right-sidebar')
      singleSidebar('right')
    when $('body').hasClass('left-sidebar')
      singleSidebar('left')
    when $('body').hasClass('two-sidebar')
      doubleSidebar()

  $('[data-toggle="offcanvas-left"]').click ->
    $('.row-offcanvas').removeClass('right-active').toggleClass('left-active')
    $(this).find('i.material-icons')
      .toggleText('chevron_left', 'chevron_right')
  $('[data-toggle="offcanvas-right"]').click ->
    $('.row-offcanvas').removeClass('left-active').toggleClass('right-active')
    $(this).find('i.material-icons')
      .toggleText('chevron_left', 'chevron_right')
