$.extend decko.editorContentFunctionMap,
    'select.pointer-select': ->
      pointerContent @val()
    'select.pointer-multiselect': ->
      pointerContent @val()
    '.pointer-radio-list': ->
      pointerContent @find('input:checked').val()
    '.pointer-list-ul': ->
      pointerContent @find('input').map( -> $(this).val() )
    '.pointer-link-list-ul': ->
      decko.linkListContent @find('.input-group')
    '._nest-list-ul': ->
      decko.nestListContent @find('.input-group')
    '.pointer-checkbox-list': ->
      pointerContent @find('input:checked').map( -> $(this).val() )
    '.pointer-select-list': ->
      pointerContent @find('.pointer-select select').map( -> $(this).val() )
    '._filtered-list': ->
      pointerContent @find('._filtered-list-item').map( -> $(this).data('cardName') )
    '._pointer-list': ->
      pointerContent @find('._pointer-item').map( -> $(this).val() )
    # can't find evidence that the following is in use: #efm
    # '.pointer-mixed': ->
    #   element = '.pointer-checkbox-sublist input:checked,\
    #             .pointer-sublist-ul input'
    #   pointerContent @find(element).map( -> $(this).val() )
    # must happen after pointer-list-ul, I think
    '.perm-editor': -> permissionsContent this

decko.editorInitFunctionMap['.pointer-list-editor'] = ->
  @sortable({handle: '.handle', cancel: ''})
  decko.initPointerList @find('input')

decko.editorInitFunctionMap['._filtered-list'] = ->
  @sortable({handle: '._handle', cancel: ''})

$.extend decko,
  initPointerList: (input) ->
    decko.initAutoCardPlete input

  pointerContent: (vals) ->
    $.makeArray(vals).join "\n"

  linkListContent: (input_groups) ->
    vals = input_groups.map( ->
      v = $(this).find('input._reference').val()
      title = $(this).find('input._title').val()
      v += "|#{title}" if title.length > 0
      v
    )
    list = $.map $.makeArray(vals), (v) -> if v then '[[' + v + ']]'
    $.makeArray(list).join "\n"

  nestListContent: (input_groups) ->
    vals = input_groups.map( ->
      v = $(this).find('input._reference').val()
      options = $(this).find('input._nest-options').val()
      v += "|#{options}" if options.length > 0
      v
    )
    list = $.map $.makeArray(vals), (v) -> if v then '{{' + v + '}}'
    $.makeArray(list).join "\n"


pointerContent = (vals) ->
  decko.pointerContent vals
  # deprecated. backwards compatibility

permissionsContent = (ed) ->
  return '_left' if ed.find('#inherit').is(':checked')
  groups = ed.find('.perm-group input:checked').map( -> $(this).val() )
  indivs = ed.find('.perm-indiv input'        ).map( -> $(this).val() )
  pointerContent $.makeArray(groups).concat($.makeArray(indivs))
