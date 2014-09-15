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


}).call(this);