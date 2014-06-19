return {
  render: (node, c) ->
    if c
      e = angular.element('#component-label_' + @_id)
    else
      e = angular.element('#node-label_' + node.$data.parent._id)
    e.addClass('underline')
#    s = if e.attr('style') then e.attr('style') else ""
#    e.attr('style', s + 'font-style: underline; ')

  generate: (node) ->
    return ""
}
