return {
  generate: (node) ->
    module = node.name.toProperCase()
    s = 'return function ' + module + '() {\n' +

    d = []
    for n in node.$data.childrenOfKind('Schema')
      model = n.name.toProperCase()
      d.push('return function ' + model + '() {\n' +
        n.generate() +
        '\n}')
    s += d.join('\n')

    return s + '}\n'
}
