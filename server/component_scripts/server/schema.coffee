return {
  generate: (node) ->
    model = node.name.toProperCase()
    schema = model + 'Schema'

    s =
      'var app = require("../app"),\n' +
      'mongoose = require("../app").mongoose,\n' +
      'timestamps = require("mongoose-time")(),\n' +
      'findOrCreate = require("mongoose-findorcreate"),\n' +
      'utils = require("../lib/mongoose-utils"),\n' +
      'mongooseEncrypted = require("mongoose-encrypted").loadTypes(mongoose),\n' +
      'encryptedPlugin = mongooseEncrypted.plugins.encryptedPlugin;\n'

    s += schema + ' = mongoose.Schema({\n'

    d = []
    for n in node.childrenOfKind(['Field'])
      d.push(n.generate(node))
    s += d.join(',\n') + '\n});\n'

    s += schema + '.plugin(timestamps);\n'
    s += schema + '.plugin(findOrCreate);\n'
    if node.childrenOfKind('Encrypted', true)
      s += schema + '.plugin(encryptedPlugin);\n'

    s += schema + '.method({\n'
    if fs.existsSync('_server/component_scripts/server/schema_methods.js')
      s += fs.readFileSync('_server/component_scripts/server/schema_methods.js')
    s += '});'

    s += schema + '.static({\n'
    if fs.existsSync('_server/component_scripts/server/schema_statics.js')
      s += fs.readFileSync('_server/component_scripts/server/schema_statics.js')
    s += '});'

    s += 'module.exports = mongoose.model(' + model + ',' + schema + ');'
}
