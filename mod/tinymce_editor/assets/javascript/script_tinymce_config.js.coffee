decko.addEditor(
  '.tinymce-textarea',
  ->
    decko.initTinyMCE @[0].id
  ->
    ed = tinyMCE.get(@[0].id)
    ed && ed.getContent()
)

decko.slotDestroy (slot) ->
  slot.find("textarea.tinymce-textarea").each ->
    ed = tinyMCE.get($(this)[0].id)
    ed && ed.remove()

$.extend decko,
  setTinyMCEConfig: (string) ->
    setter = ->
      try
        $.parseJSON string
      catch
        {}
    decko.tinyMCEConfig = setter()

  initTinyMCE: (el_id) ->
    # verify_html: false -- note: this option needed for empty
    #                             paragraphs to add space.
    conf = {
      theme: "silver"
      plugins: 'autoresize'
      autoresize_max_height: 500
      mobile: { theme: 'mobile' }
      contextmenu: "deckolink nest"
    }
    user_conf = if decko.tinyMCEConfig? then decko.tinyMCEConfig else {}
    hard_conf = {
      selector: "##{el_id}"
      branding: false
      extended_valid_elements: "card-nest[id]"
      # CSS could be made optional, but it may involve migrating old legacy
      # *tinyMCE settings to get rid of stale stuff.
      content_css: decko.cssPath
      entity_encoding: 'raw'
    }
    $.extend conf, user_conf, hard_conf
    decko.addNestPlugin(conf)


    tinyMCE.baseURL = decko.path('assets/tinymce_editor/tinymce')
    tinyMCE.suffix = '.min'
    # "##{el_id}"
    # tinyMCE.get(el_id).remove() if $("##{el_id}")[0]? and tinyMCE.get(el_id)?
    tinyMCE.init conf

  addNestPlugin: (conf) ->
    if conf.plugins?  then conf.plugins += " nest"    else conf.plugins = "nest"
    # if conf.toolbar1? then conf.toolbar1 += " | nest" else conf.toolbar1 = "nest"
    conf.menu = { insert: { title: "Insert", items: "deckolink nest image | hr"}}


