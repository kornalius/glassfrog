'use strict';

(function() {
  var app = require("../app");
  var mongoose = require("mongoose");
  var timestampPlugin = require("mongoose-time")();
  var mongooseCurrency = require("mongoose-currency").loadType(mongoose);
  var mongooseSetter = require("mongoose-setter")(mongoose);
  var mongoosePercent = require("../mongoose_plugins/mongoose-percent")(mongoose);
  //var mongooseMoment = require("mongoose-moment")(mongoose);
  var mongooseEncrypted = require("mongoose-encrypted").loadTypes(mongoose);
  var mongooseVersion = require("../mongoose_plugins/mongoose-version")();
  var schemaExtend = require("mongoose-schema-extend");


  var PlaneSchema = B9d14429f6fc96f4384104d0Schema.extend({
    'FlightNo': {
      type: String,
      'index': false,
      'required': true,
      'private': false,
      'readOnly': false,
      'select': true,
      'populate': false,
      'trim': true,
      'encrypt': false,
      'password': false
    },
    'SeatNo': {
      type: mongoosePercent,
      round: 2,
      'index': false,
      'required': false,
      'private': false,
      'readOnly': false,
      'select': true,
      'populate': false,
      'trim': false,
      'encrypt': false,
      'password': false
    }

  }, {
    discriminatorKey: '_type'
  });

  PlaneSchema.plugin(timestampPlugin);

  PlaneSchema.methods.MyMethod = function() {
    console.log('Very Nice!', false, 10, moment('10/07/2014'), moment('4:14 PM'), moment('10/07/2014 4:14 PM'), tinycolor('#ff000000'), '');
  };




  module.exports.PlaneSchema = PlaneSchema

  exports.schemas = [Plane]
  exports.queries = []
  exports.pages = []
  exports.views = []


}).call(this);