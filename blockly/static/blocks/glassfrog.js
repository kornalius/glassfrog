goog.provide('Blockly.Blocks.glassfrog');

goog.require('Blockly.Blocks');

Blockly.Blocks['glassfrog_schema'] = {
  init: function() {
    this.setHelpUrl('');
    this.setColour(240);
    this.appendDummyInput()
        .appendField("schema")
        .appendField(new Blockly.FieldVariable("name"), "name");
    this.appendStatementInput("fields")
        .setCheck("glassfrog_field")
        .setAlign(Blockly.ALIGN_RIGHT)
        .appendField("fields");
    this.appendStatementInput("methods")
        .setAlign(Blockly.ALIGN_RIGHT)
        .appendField("methods");
    this.setTooltip('');
  }
};

//Blockly.Blocks['glassfrog_schema'] = {
//  init: function() {
//    this.setHelpUrl('');
//    this.setColour(20);
//    this.appendDummyInput()
////        .appendField(new Blockly.FieldImage("/img/schema.png", 16, 16, ""))
//        .appendField("schema")
//        .appendField(new Blockly.FieldVariable("name"), "name");
//    this.appendValueInput("fields")
//        .setCheck("Array")
//        .setAlign(Blockly.ALIGN_RIGHT)
//        .appendField("fields");
//    this.appendValueInput("methods")
//        .setCheck("Array")
//        .setAlign(Blockly.ALIGN_RIGHT)
//        .appendField("methods");
//    this.appendValueInput("statics")
//        .setCheck("Array")
//        .setAlign(Blockly.ALIGN_RIGHT)
//        .appendField("statics");
////    this.setOutput(true, "glassfrog_schema");
//    this.setTooltip('');
//  }
//};

Blockly.Blocks['glassfrog_field'] = {
  init: function() {
    this.setHelpUrl('');
    this.setColour(330);
    this.appendDummyInput()
        .appendField("field")
        .appendField(new Blockly.FieldVariable("name"), "name")
        .appendField("of type")
        .appendField(new Blockly.FieldDropdown([["String", "String"], ["Number", "Number"], ["Boolean", "Boolean"], ["Date", "Date"], ["Array", "Array"], ["Mixed", "Mixed"], ["ObjectId", "mongoose.Schema.ObjectId"], ["Buffer", "Buffer"]]), "type");
    this.appendDummyInput()
        .appendField("label")
        .appendField(new Blockly.FieldTextInput(""), "label");
    this.appendDummyInput()
        .appendField("default")
        .appendField(new Blockly.FieldTextInput(""), "default");
    this.appendStatementInput("options")
        .setCheck("glassfrog_fieldoption")
        .appendField("options");
    this.setOutput(true, 'glassfrog_field');
    this.setInputsInline(true);
    this.setPreviousStatement(true, "glassfrog_field");
    this.setNextStatement(true, "glassfrog_field");
    this.setTooltip('');
  }
};

//Blockly.Blocks['glassfrog_field'] = {
//  init: function() {
//    this.setHelpUrl('');
//    this.setColour(210);
//    this.appendDummyInput()
//        .appendField(new Blockly.FieldTextInput("name"), "name")
//        .appendField("of type")
//        .appendField(new Blockly.FieldDropdown([["String", "String"], ["Number", "Number"], ["Boolean", "Boolean"], ["Date", "Date"], ["Array", "Array"], ["Mixed", "Mixed"], ["ObjectId", "mongoose.Schema.ObjectId"], ["Buffer", "Buffer"]]), "type");
//    this.appendValueInput("label")
//        .setCheck("String")
//        .setAlign(Blockly.ALIGN_RIGHT)
//        .appendField("label");
//    this.appendValueInput("default")
//        .setAlign(Blockly.ALIGN_RIGHT)
//        .appendField("default");
//    this.appendValueInput("options")
//        .setCheck("Array")
//        .setAlign(Blockly.ALIGN_RIGHT)
//        .appendField("options");
//    this.appendValueInput("subfields")
//        .setCheck("Array")
//        .setAlign(Blockly.ALIGN_RIGHT)
//        .appendField("sub-fields");
//    this.setOutput(true, "glassfrog_field");
//    this.setTooltip('');
//  }
//};

Blockly.Blocks['glassfrog_fieldoption'] = {
  init: function() {
    this.setHelpUrl('');
    this.setColour(180);
    this.appendDummyInput()
        .appendField(new Blockly.FieldDropdown([["required", "required"], ["unique", "unique"], ["trim", "trim"], ["read-only", "readOnly"], ["private", "private"], ["inline", "inline"], ["populate", "populate"], ["index", "index"], ["match", "match"], ["min", "min"], ["max", "max"], ["enum", "enum"]]), "key");
    this.appendValueInput("value");
    this.setInputsInline(true);
    this.setPreviousStatement(true, "glassfrog_fieldoption");
    this.setNextStatement(true, "glassfrog_fieldoption");
    this.setTooltip('');
  }
};

//Blockly.Blocks['glassfrog_fieldOption'] = {
//  init: function() {
//    this.setHelpUrl('');
//    this.setColour(120);
//    this.appendDummyInput()
//        .appendField(new Blockly.FieldDropdown([["required", "required"], ["unique", "unique"], ["trim", "trim"], ["read-only", "readOnly"], ["private", "private"], ["inline", "inline"], ["populate", "populate"], ["index", "index"], ["match", "match"], ["min", "min"], ["max", "max"], ["enum", "enum"]]), "name");
//    this.appendValueInput("value")
//        .setAlign(Blockly.ALIGN_RIGHT);
//    this.setInputsInline(true);
//    this.setOutput(true, null);
//    this.setTooltip('');
//  }
//};
