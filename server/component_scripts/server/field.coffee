return {
  generate: (node) ->
    field = node.name.toLowerCase()
    s = field + ":{\n"

    d = []
    for n in node.childOfKind(['Attribute', 'Validator'])
      d.push(n.generate(node))

    return s + d.join(',\n') + '\n}\n'
}
