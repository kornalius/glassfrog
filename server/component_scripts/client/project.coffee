return {
  render: (node, c) ->
    if !c
      e = angular.element('#node-label_' + node._id)
      s = if e.attr('style') then e.attr('style') else ""
      e.attr('style', s + 'font-weight: bold; ')

generate: (node) ->
    return ""
}
