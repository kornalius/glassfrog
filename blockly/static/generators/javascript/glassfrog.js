goog.provide('Blockly.JavaScript.glassfrog');

goog.require('Blockly.JavaScript');

if(!String.prototype.format) {
  String.prototype.format = function() {
    var args = arguments;
    return (this.replace(/{(\d+)}/g, function(match, number) {
      return(typeof args[number] != 'undefined' ? args[number] : match);
    }));
  }
}

if(!String.prototype.toProperCase) {
  String.prototype.toProperCase = function() {
    return(this.replace(/\w\S*/g, function (txt) {
      return(txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase());
    }));
  }
}

Blockly.JavaScript['glassfrog_schema'] = function(block) {
  var _name = Blockly.JavaScript.variableDB_.getName(block.getFieldValue('name'), Blockly.Variables.NAME_TYPE);
  var _fields = Blockly.JavaScript.statementToCode(block, 'fields');
  var _methods = Blockly.JavaScript.statementToCode(block, 'methods');

  var code =

  'app = require("../app");\n' +
  'mongoose = require("../app").mongoose;\n' +
  'timestamps = require("mongoose-time")();\n' +
  'async = require("async");\n' +
  '\n' +

  '{3}Schema = mongoose.Schema({\n' +
  '{1}\n' +
  '});\n' +
  '\n' +

  '{3}Schema.plugin(timestamps);\n' +
  '\n' +

  '{3}Schema.method({\n' +
  '{2}\n' +
  '});\n' +
  '\n' +

//  '{3}Schema.static({\n' +
//  '{3}\n' +
//  '});\n' +
//  '\n' +

  '{0} = mongoose.model("{3}", {3}Schema);\n' +
  'module.exports = {0};\n';

  return code.format(_name, _fields, _methods, _name.toProperCase());
};

//Blockly.JavaScript['glassfrog_schema'] = function(block) {
//  var _name = Blockly.JavaScript.variableDB_.getName(block.getFieldValue('name'), Blockly.Variables.NAME_TYPE);
//  var _fields = Blockly.JavaScript.valueToCode(block, 'fields', Blockly.JavaScript.ORDER_ATOMIC);
//  var _methods = Blockly.JavaScript.valueToCode(block, 'methods', Blockly.JavaScript.ORDER_ATOMIC);
//  var _statics = Blockly.JavaScript.valueToCode(block, 'statics', Blockly.JavaScript.ORDER_ATOMIC);
//
//  var code =
//
//  'app = require("../app");\n' +
//  'mongoose = require("../app").mongoose;\n' +
//  'timestamps = require("mongoose-time")();\n' +
//  'async = require("async");\n' +
//  '\n' +
//
//  '{4}Schema = mongoose.Schema(\n' +
//  '  {1}\n' +
//  ');\n' +
//  '\n' +
//
//  '{4}Schema.plugin(timestamps);\n' +
//  '\n' +
//
//  '{4}Schema.method({\n' +
//  '  {2}\n' +
//  '});\n' +
//  '\n' +
//
//  '{4}Schema.static({\n' +
//  '  {4}\n' +
//  '});\n' +
//  '\n' +
//
//  '{0} = mongoose.model("{4}", {4}Schema);\n' +
//  'module.exports = {0};\n';
//
//  return [code.format(_name, _fields, _methods, _statics, _name.toProperCase()), Blockly.JavaScript.ORDER_NONE];
//};

Blockly.JavaScript['glassfrog_field'] = function(block) {
  var _name = Blockly.JavaScript.variableDB_.getName(block.getFieldValue('name'), Blockly.Variables.NAME_TYPE);
  var _type = block.getFieldValue('type');
  var _label = block.getFieldValue('label');
  var _default = block.getFieldValue('default');
  var _options = Blockly.JavaScript.statementToCode(block, 'options');

  var code =

  '"' + _name + '": {\n' +
  '  type: ' + _type;

  if (_default && _default.length) {
    code += ',\n  default: "' + _default + '"'
  }

  if (_label && _label.length) {
    code += ',\n  label: "' + _label + '"'
  }

  if (_options && _options.length) {
    code += ',\n' + _options
  }

  code += '\n}';

  if (block.getNextBlock()) {
    code += ',';
  }

  code += '\n';

  return code.replace('\n\n', '\n');
};

//Blockly.JavaScript['glassfrog_field'] = function(block) {
//  var _name = Blockly.JavaScript.variableDB_.getName(block.getFieldValue('name'), Blockly.Variables.NAME_TYPE);
//  var _type = block.getFieldValue('type');
//  var _label = Blockly.JavaScript.valueToCode(block, 'label', Blockly.JavaScript.ORDER_ATOMIC);
//  var _default = Blockly.JavaScript.valueToCode(block, 'default', Blockly.JavaScript.ORDER_ATOMIC);
//  var _options = Blockly.JavaScript.valueToCode(block, 'options', Blockly.JavaScript.ORDER_ATOMIC);
//  var _subfields = Blockly.JavaScript.valueToCode(block, 'subfields', Blockly.JavaScript.ORDER_ATOMIC);
//
//  var code = '';
//
//  if (_subfields && _subfields.length) {
//    code =
//    '{\n' +
//    '  "{0}": {\n' +
//    '    type: {6}{\n' +
//    '      {5}\n' +
//    '    }{7},\n' +
//    '    label: {2},\n' +
//    '    {4}\n' +
//    '  }\n' +
//    '}\n';
//  } else {
//    code =
//    '{\n' +
//    '  "{0}": {\n' +
//    '    type: {6}{1}{7},\n' +
//    '    default: {3},\n' +
//    '    label: {2},\n' +
//    '    {4}\n' +
//    '  }\n' +
//    '}\n';
//  }
//
//  return [code.format(_name, _type, _label, _default, _options, _subfields, (_type === 'Array' ? '[' : ''), (_type === 'Array' ? ']' : '')), Blockly.JavaScript.ORDER_NONE];
//};

Blockly.JavaScript['glassfrog_fieldoption'] = function(block) {
  var _key = block.getFieldValue('key');
  var _value = Blockly.JavaScript.valueToCode(block, 'value', Blockly.JavaScript.ORDER_ATOMIC);

  var code = '';

  if (_value && _value.length) {
    code = _key + ':' + _value;

    if (block.getNextBlock()) {
      code += ',';
    }

    code += '\n';
  }

  return code;
};

//Blockly.JavaScript['glassfrog_fieldOption'] = function(block) {
//  var _name = block.getFieldValue('name');
//  var _value = Blockly.JavaScript.valueToCode(block, 'value', Blockly.JavaScript.ORDER_ATOMIC);
//
//  var code = '  {0}: {1}\n,';
//
//  return code.format(_name, _value);
//};
