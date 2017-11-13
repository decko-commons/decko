decko.addEditor(
  '.tinymce-textarea',
  ->
    decko.initTinyMCE @[0].id
  ->
    tinyMCE.get(@[0].id).getContent()
)

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
      theme: "modern",
      plugins: 'autoresize code lists hr link autolink table contextmenu textcolor colorpicker'
      autoresize_max_height: 500,
      toolbar1: 'formatselect | bold italic strikethrough forecolor backcolor | link | alignleft aligncenter alignright alignjustify  | numlist bullist outdent indent  | removeformat'
    }
    user_conf = if decko.tinyMCEConfig? then decko.tinyMCEConfig else {}
    hard_conf = {
      selector: "##{el_id}",
      branding: false
      # CSS could be made optional, but it may involve migrating old legacy
      # *tinyMCE settings to get rid of stale stuff.
      content_css: decko.cssPath
      entity_encoding: 'raw'
    }
    $.extend conf, user_conf, hard_conf
    tinyMCE.baseURL = '/assets/tinymce'
    tinyMCE.suffix = '.min'
    tinyMCE.init conf
