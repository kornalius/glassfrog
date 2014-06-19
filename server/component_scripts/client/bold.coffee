return {
  render: (node, c) ->
    if c
      e = angular.element('#component-label_' + @_id)
    else
      e = angular.element('#node-label_' + node.$data.parent._id)
    e.addClass('bold')
#    s = if e.attr('style')? then e.attr('style') else ""
#    e.attr('style', s + 'font-weight: bold; ')
#    console.log "bold", e.attr('style')

  generate: (node) ->
    return ""
}
