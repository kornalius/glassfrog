/*3da31e9b9b3f9edf39de9993*/
'use strict';

(function() {
  var app = require('../app');
  var mongoose = require('mongoose');
  var timestampPlugin = require('mongoose-time')();
  var mongooseCurrency = require('mongoose-currency').loadType(mongoose);
  var mongooseSetter = require('mongoose-setter')(mongoose);
  var mongoosePercent = require('../mongoose_plugins/mongoose-percent')(mongoose);
  // var mongooseMoment = require('mongoose-moment')(mongoose);
  var mongooseEncrypted = require('mongoose-encrypted').loadTypes(mongoose);
  var mongooseVersion = require('../mongoose_plugins/mongoose-version')();
  var schemaExtend = require('mongoose-schema-extend');

  /*a7fb208ec2f68c285ac5bf5f*/
  var PlaneSchema = mongoose.Schema({
    /*623ba3a4988769c76fee88ac*/
    'field': { /*5b435e5acf8c925aa3f811c6*/ /*9c614ddcaff6fbebd21a1817*/
      type: mongoose.SchemaTypes.Encrypted,
      method: 'pbkdf2',
      encryptOptions: {
        iterations: 4096,
        keyLength: 32,
        saltLength: 64
      },
      required: true,
      'private': true,
      readOnly: true,
      select: false
    },
    /*44294793f6b47a28a5f1d960*/
    'userId': { /*7a8c4e222b0d00b6caf768c9*/
      type: mongoose.SchemaTypes.ObjectId,
      ref: 'User'
    },
    /*b104316fdf477500a0cfc286*/
    'flightNo': { /*e08dd086998cc25ca587afff*/
      type: String,
      required: true
    },
    /*4bb3fe6927757de9b4370943*/
    'seatNo': { /*a90bd878b0ef6f51e3945ebf*/
      type: mongoosePercent,
      /*d32a2d33bbe81783e345aa67*/
      round: 2
    }
  });

  PlaneSchema.plugin(timestampPlugin);

  /*a034c38db81d07983bf1959b*/
  PlaneSchema.methods.myMethod = function(arg1) { /*6122ba88b93c5236bae52666*/
    console.log('Very Nice!', false, 10, moment('11/04/2014'), moment('10:42 AM'), moment('11/04/2014 10:42 AM'), tinycolor('#ff000000'), '');
  }

  module.exports.PlaneSchema = PlaneSchema;

  exports.schemas = [plane]
  exports.queries = []
  exports.pages = [page]
  exports.views = [view]
  exports.forms = [form]
}).call(this);