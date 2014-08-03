if !String::toProperCase
  String::toProperCase = ->
    return @replace(/\w\S*/g, (txt) ->
      return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase()
    )

if !String::downcase
  String::downcase = -> @toLowerCase()

if !String::upcase
  String::upcase = -> @toUpperCase()

if !String::propercase
  String::propercase = -> @toProperCase()

if !String::trim
  String::trim = -> @replace /^\s+|\s+$/g, ""

if !String::ltrim
  String::ltrim = -> @replace /^\s+/g, ""

if !String::rtrim
  String::rtrim = -> @replace /\s+$/g, ""

if !String::format
  String::format = () ->
    args = arguments
    return @replace(/{(\d+)}/g, (match, number) ->
      return if typeof args[number] != 'undefined' then args[number] else match
    )

if !String::startsWith
  String::startsWith = (searchString, position) ->
    position = if position? then position else 0
    return @indexOf(searchString, position) == position

if !String::endsWith
  String::endsWith = (searchString, position) ->
    position = if position? then position else (@length - searchString.length)
    return @indexOf(searchString, position) == position

#if !String::humanize
#  String::humanize = () ->
#    return @replace(/[_-]/g, ' ').toProperCase()

if !Array::filter
  Array::filter = (callback) ->
    element for element in this when callback(element)

if !Array::diff
  Array::diff = (a) ->
    return @filter((i) ->
      return a.indexOf(i) < 0
    )

if !Array::zip
  Array::zip = () ->
    lengthArray = (arr.length for arr in arguments)
    length = Math.min(lengthArray...)
    for i in [0...length]
      arr[i] for arr in arguments

if !Array::unique
  Array::unique = ->
    output = {}
    output[@[key]] = @[key] for key in [0..@length - 1]
    value for key, value of output

if !Array::toDict
  Array::toDict = (key) ->
    dict = {}
    dict[obj[key]] = obj for obj in this when obj[key]?
    return dict

if !Array::where
  Array::where = (query) ->
    return [] if typeof query isnt "object"
    hit = Object.keys(query).length
    @filter (item) ->
      match = 0
      for key, val of query
        match += 1 if item[key] is val
      if match is hit then true else false



exp = {}

exp.type = (obj) ->
  if obj == undefined or obj == null
    return String obj
  classToType = {
    '[object Boolean]': 'boolean',
    '[object Number]': 'number',
    '[object String]': 'string',
    '[object Function]': 'function',
    '[object Array]': 'array',
    '[object Date]': 'date',
    '[object RegExp]': 'regexp',
    '[object Object]': 'object'
  }
  return classToType[Object.prototype.toString.call(obj)]

exp.checksum = (str) ->
  i = 0
  chk = 0x12345678
  for i in [0..str.length - 1]
    chk += str.charCodeAt(i) * (i + 1)
  return chk

exp.makeId = () ->
  guid = () ->
    s4 = () ->
      return Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1)
    return s4() + s4() + s4() + s4() + s4() + s4()
  return guid()


for k of exp
  if window? and !window[k]
    window[k] = exp[k]
  else if global? and !global[k]
    global[k] = exp[k]
