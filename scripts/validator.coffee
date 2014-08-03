assurance = null

_validateField = (assure, field) ->

  patterns =
    date:
      pattern: /^\d{4}([./-])\d{2}\1\d{2}$/
      msg: 'invalid date'

    time:
      pattern: /^\d{1,2}:\d{1,2}(:\d{1,2})?\s?(am|pm)??$/i
      msg: 'invalid time'

    datetime:
      pattern: /^\d{4}([./-])\d{2}\1\d{2}\s\d{1,2}:\d{1,2}(:\d{1,2})?\s?(am|pm)?$/i
      msg: 'invalid date and/or time'

    email:
      pattern: /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/i
      msg: 'email is invalid'

    lowercase:
      pattern: /^[a-z]+$/
      msg: 'all letters must be lowercase'

    uppercase:
      pattern: /^[A-Z]+$/
      msg: 'all letters must be uppercase'

    propercase:
      pattern: /^[A-Z][a-z]+$/
      msg: ''

    float:
      pattern: /^(\-?[1-9]{1}[\d]{0,2}(\,[\d]{3})*(\.[\d]{0,2})?|[1-9]{1}[\d]{0,}(\.[\d]{0,2})?|0(\.[\d]{0,2})?|(\.[\d]{1,2})?)$/
      msg: 'invalid number'

    money:
      pattern: /^(\-?\$?([1-9]\d{0,2}(\,\d{3})*|[1-9]\d*|0|)(\.\d{1,2})?|\(\$?([1-9]\d{0,2}(\,\d{3})*|[1-9]\d*|0|)(\.\d{1,2})?\))$/
      msg: 'invalid money value'

    url:
      pattern: /((([A-Za-z]{3,9}:(?:\/\/)?)(?:[-;:&=+$,\w]+@)?[A-Za-z0-9.-]+|(?:www.|[-;:&=+$,\w]+@)[A-Za-z0-9.-]+)((?:\/[+~%\/.-_\w]*)?\??(?:[-+=&;%@._\w]*)#?(?:[\w]*))?)/i
      msg: 'invalid url'

    ip:
      pattern: /^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$/
      msg: 'invalid ip address'

    domain:
      pattern: /^(?:[a-zA-Z0-9]+(?:\-*[a-zA-Z0-9])*\.)+[a-zA-Z]{2,6}$/
      msg: 'invalid domain name'

    alpha:
      pattern: /^[a-z]+$/i
      msg: 'must be letters only'

    alphanum:
      pattern: /^[a-z0-9]+$/i
      msg: 'must be letters or numbers'

    username:
      pattern: /^[a-z]+[a-z0-9]{3}$/i
      msg: 'must start with a letter and contains at least 4 letters and/or digits'

    hex:
      pattern: /^[0-9a-f]$/i
      msg: 'invalid hexadecimal value'

    creditcard:
      pattern: /^((4\d{3})|(5[1-5]\d{2})|(6011))-?\d{4}-?\d{4}-?\d{4}|3[4,7]\d{13}$/
      msg: 'invalid credit card number'

    boolean:
      pattern: /^(0|1|true|false|t|f|yes|no|y|n|ok)$/i
      msg: 'invalid boolean value'


  if field.required
    assure.me(field.fieldname).required().custom((val, errors) ->
      if !val? or val.length == 0
        return new errors.MissingParameter('this parameter is required', val)
      else
        return null
    )

  if field.number
    assure.me(field.fieldname).isInt()

  if field.positive
    assure.me(field.fieldname).gt(0)

  if field.negative
    assure.me(field.fieldname).lt(0)

  if field.range
    assure.me(field.fieldname).min(field.range.min)
    assure.me(field.fieldname).max(field.range.max)

  if field.min and !field.range
    assure.me(field.fieldname).min(field.min)

  if field.max and !field.range
    assure.me(field.fieldname).max(field.max)

  if field.equals
    assure.me(field.fieldname).equals(field.equals)

  if field.notEquals
    assure.me(field.fieldname).equals(field.notEquals)

  if field.oneOf
    assure.me(field.fieldname).oneOf(field.oneOf)

  if field.maxLength
    assure.me(field.fieldname).len(field.maxLength)

  if field.minLength and field.maxLength
    assure.me(field.fieldname).len(field.minLength, field.maxLength)

  if field.matches
    assure.me(field.fieldname).matches(field.matches)

  for k of patterns
    if field[k]? and assure.object[field.fieldname]?
      e = assure.me(field.fieldname).matches(patterns[k].pattern)
      if e and e.errors
        for ee in e.errors
          ee.message = patterns[k].msg

  return if assure.errors.length then assure.errors else null

vd =
  validate: (rows, fields, idx) ->
    errors = []

    if idx?
      rows = [rows[idx]]
      i = idx
    else
      i = 0

    for r in rows
      for f in fields
        assure = assurance.restart(r)
        e = _validateField(assure, f)
        if e
          for ee in e
            errors.push(
              idx: i
              field: f.fieldname
              value: r[f.fieldname]
              message: ee.message
              type: ee.type
            )
        assure.end()
      i++

    return if errors.length then errors else null


  validateField: (rows, field, idx) ->
    return @validate(rows, [field], idx)


if define?
  define('validator', ['assurance'], (ad) ->
    assurance = ad
    return vd
  )
else
  assurance = require('assurance')
  module.exports = vd
