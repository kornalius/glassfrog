goog.provide('Blockly.JavaScript.glassfrog');

goog.require('Blockly.JavaScript');

Blockly.JavaScript['glassfrog_schema'] = function(block) {
  var _name = Blockly.JavaScript.variableDB_.getName(block.getFieldValue('name'), Blockly.Variables.NAME_TYPE);
  var _fields = Blockly.JavaScript.valueToCode(block, 'fields', Blockly.JavaScript.ORDER_ATOMIC);
  var _methods = Blockly.JavaScript.valueToCode(block, 'methods', Blockly.JavaScript.ORDER_ATOMIC);
  var _statics = Blockly.JavaScript.valueToCode(block, 'statics', Blockly.JavaScript.ORDER_ATOMIC);

  var code =

  'app = require("../app");\n' +
  'mongoose = require("../app").mongoose;\n' +
  'timestamps = require("mongoose-time")();\n' +
  'async = require("async");\n' +
  '\n' +

  '{4}Schema = mongoose.Schema(\n' +
  '  {1}\n' +
  ');\n' +
  '\n' +

  '{4}Schema.plugin(timestamps);\n' +
  '\n' +

  '{4}Schema.method({\n' +
  '  {2}\n' +
  '});\n' +
  '\n' +

  '{4}Schema.static({\n' +
  '  {4}\n' +
  '});\n' +
  '\n' +

  '{0} = mongoose.model("{4}", {4}Schema);\n' +
  'module.exports = {0};\n';

  return [code.format(_name, _fields, _methods, _statics, _name.toProperCase()), Blockly.JavaScript.ORDER_NONE];
};

Blockly.JavaScript['glassfrog_field'] = function(block) {
  var _name = Blockly.JavaScript.variableDB_.getName(block.getFieldValue('name'), Blockly.Variables.NAME_TYPE);
  var _type = block.getFieldValue('type');
  var _label = Blockly.JavaScript.valueToCode(block, 'label', Blockly.JavaScript.ORDER_ATOMIC);
  var _default = Blockly.JavaScript.valueToCode(block, 'default', Blockly.JavaScript.ORDER_ATOMIC);
  var _options = Blockly.JavaScript.valueToCode(block, 'options', Blockly.JavaScript.ORDER_ATOMIC);
  var _subfields = Blockly.JavaScript.valueToCode(block, 'subfields', Blockly.JavaScript.ORDER_ATOMIC);

  var code = '';

  if (_subfields && _subfields.length) {
    code =
    '{\n' +
    '  "{0}": {\n' +
    '    type: {6}{\n' +
    '      {5}\n' +
    '    }{7},\n' +
    '    label: {2},\n' +
    '    {4}\n' +
    '  }\n' +
    '}\n';
  } else {
    code =
    '{\n' +
    '  "{0}": {\n' +
    '    type: {6}{1}{7},\n' +
    '    default: {3},\n' +
    '    label: {2},\n' +
    '    {4}\n' +
    '  }\n' +
    '}\n';
  }

  return [code.format(_name, _type, _label, _default, _options, _subfields, (_type === 'Array' ? '[' : ''), (_type === 'Array' ? ']' : '')), Blockly.JavaScript.ORDER_NONE];
};

Blockly.JavaScript['glassfrog_fieldOption'] = function(block) {
  var _name = block.getFieldValue('name');
  var _value = Blockly.JavaScript.valueToCode(block, 'value', Blockly.JavaScript.ORDER_ATOMIC);

  var code = '  {0}: {1}\n,';

  return code.format(_name, _value);
};
