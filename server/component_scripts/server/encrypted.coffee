return {
  generate: (node) ->
    'type: mongoose.SchemaTypes.Encrypted,\n' +
    'minLength: 4,\n' +
    'method: "pbkdf2",\n' +
    'encryptOptions: {\n' +
    '  iterations: 4096,\n' +
    '  keyLength: 32,\n' +
    '  saltLength: 64\n' +
    '}'
}
