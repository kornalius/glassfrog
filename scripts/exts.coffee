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
    if position > searchString.length - 1
      return false
    else
      return @indexOf(searchString, position) == position

if !String::endsWith
  String::endsWith = (searchString, position) ->
    position = if position? then position else (@length - searchString.length)
    if position < 0
      return false
    else
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


if !window?
  log = console.log
  console.log = () ->
#    console.trace "console.log()"
    util = require('util')
    ansi = require('simple-ansi')
    Moment = require('moment')
    l = []
    for a in Array.prototype.slice.call(arguments)
      if type(a) is 'object'
        l.push(util.inspect(a, {depth: 2, colors: true}).replace(/\s+/g,' ').replace(/\n/g,''))
#        l.push(serialize(a))
      else
        l.push(if a? then a else '{red}undefined{reset}')
    t = l.join(' ')
    for c in ['blue', 'red', 'green', 'cyan', 'yellow', 'magenta', 'bgGray', 'bgRed', 'bgGreen', 'bgYellow', 'bgBlue', 'bgMagenta', 'bgCyan', 'white', 'black', 'bold', 'italic', 'underline', 'reset']
      while t.toLowerCase().indexOf('{' + c + '}') != -1
        t = t.replace('{' + c + '}', ansi[c], 'gi')
    util.puts "{0} [{1}.{2}:{3}] {4}".format(ansi.reset + ansi.blue + new Moment().format('hh:mm:ss.S') + ansi.reset, ansi.cyan + ansi.underline + __file__, __ext__ + ansi.yellow, __line__ + ansi.reset, t)

  Object.defineProperty(global, '__stack__',
    get: ->
      orig = Error.prepareStackTrace
      Error.prepareStackTrace = (_, stack) -> return stack
      err = new Error
      Error.captureStackTrace(err, arguments.callee)
      stack = err.stack
      Error.prepareStackTrace = orig
      return stack
  )

  Object.defineProperty(global, '__line__',
    get: ->
      if  __stack__[2]
        return __stack__[2].getLineNumber()
      else
        return 0
  )

  Object.defineProperty(global, '__file__',
    get: ->
      if  __stack__[2] and __stack__[2].getFileName()
        return __stack__[2].getFileName().split('/').slice(-1)[0].split('.').slice(0)[0]
      else
        return ''
  )

  Object.defineProperty(global, '__ext__',
    get: ->
      if  __stack__[2] and __stack__[2].getFileName()
        return __stack__[2].getFileName().split('.').slice(-1)[0]
      else
        return ''
  )

  Object.defineProperty(global, '__dir__',
    get: ->
      if  __stack__[2] and __stack__[2].getFileName()
        filename = __stack__[2].getFileName().split('/').slice(-1)[0]
        return __stack__[2].getFileName().split(filename).slice(0)[0]
      else
        return ''
  )

exp = {}

exp.jsonToString = (obj, cb) ->
  s = ''
  e = null
  try
    s = CircularJSON.stringify(obj)
  catch err
    e = err
    console.log e
    throw e
  if cb
    cb(e, s)
  else
    return s

exp.stringToJson = (str, cb) ->
  json = null
  e = null
  try
    json = CircularJSON.parse(str)
  catch err
    e = err
    console.log e
    throw e
  if cb
    cb(e, json)
  else
    return json

exp.type = (obj) ->
  if obj == undefined or obj == null
    return String obj
  classToType =
    '[object Boolean]': 'boolean'
    '[object Number]': 'number'
    '[object String]': 'string'
    '[object Function]': 'function'
    '[object Array]': 'array'
    '[object Date]': 'date'
    '[object RegExp]': 'regexp'
    '[object Object]': 'object'
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

a_table = "00000000 77073096 EE0E612C 990951BA 076DC419 706AF48F E963A535 9E6495A3 0EDB8832 79DCB8A4 E0D5E91E 97D2D988 09B64C2B 7EB17CBD E7B82D07 90BF1D91 1DB71064 6AB020F2 F3B97148 84BE41DE 1ADAD47D 6DDDE4EB F4D4B551 83D385C7 136C9856 646BA8C0 FD62F97A 8A65C9EC 14015C4F 63066CD9 FA0F3D63 8D080DF5 3B6E20C8 4C69105E D56041E4 A2677172 3C03E4D1 4B04D447 D20D85FD A50AB56B 35B5A8FA 42B2986C DBBBC9D6 ACBCF940 32D86CE3 45DF5C75 DCD60DCF ABD13D59 26D930AC 51DE003A C8D75180 BFD06116 21B4F4B5 56B3C423 CFBA9599 B8BDA50F 2802B89E 5F058808 C60CD9B2 B10BE924 2F6F7C87 58684C11 C1611DAB B6662D3D 76DC4190 01DB7106 98D220BC EFD5102A 71B18589 06B6B51F 9FBFE4A5 E8B8D433 7807C9A2 0F00F934 9609A88E E10E9818 7F6A0DBB 086D3D2D 91646C97 E6635C01 6B6B51F4 1C6C6162 856530D8 F262004E 6C0695ED 1B01A57B 8208F4C1 F50FC457 65B0D9C6 12B7E950 8BBEB8EA FCB9887C 62DD1DDF 15DA2D49 8CD37CF3 FBD44C65 4DB26158 3AB551CE A3BC0074 D4BB30E2 4ADFA541 3DD895D7 A4D1C46D D3D6F4FB 4369E96A 346ED9FC AD678846 DA60B8D0 44042D73 33031DE5 AA0A4C5F DD0D7CC9 5005713C 270241AA BE0B1010 C90C2086 5768B525 206F85B3 B966D409 CE61E49F 5EDEF90E 29D9C998 B0D09822 C7D7A8B4 59B33D17 2EB40D81 B7BD5C3B C0BA6CAD EDB88320 9ABFB3B6 03B6E20C 74B1D29A EAD54739 9DD277AF 04DB2615 73DC1683 E3630B12 94643B84 0D6D6A3E 7A6A5AA8 E40ECF0B 9309FF9D 0A00AE27 7D079EB1 F00F9344 8708A3D2 1E01F268 6906C2FE F762575D 806567CB 196C3671 6E6B06E7 FED41B76 89D32BE0 10DA7A5A 67DD4ACC F9B9DF6F 8EBEEFF9 17B7BE43 60B08ED5 D6D6A3E8 A1D1937E 38D8C2C4 4FDFF252 D1BB67F1 A6BC5767 3FB506DD 48B2364B D80D2BDA AF0A1B4C 36034AF6 41047A60 DF60EFC3 A867DF55 316E8EEF 4669BE79 CB61B38C BC66831A 256FD2A0 5268E236 CC0C7795 BB0B4703 220216B9 5505262F C5BA3BBE B2BD0B28 2BB45A92 5CB36A04 C2D7FFA7 B5D0CF31 2CD99E8B 5BDEAE1D 9B64C2B0 EC63F226 756AA39C 026D930A 9C0906A9 EB0E363F 72076785 05005713 95BF4A82 E2B87A14 7BB12BAE 0CB61B38 92D28E9B E5D5BE0D 7CDCEFB7 0BDBDF21 86D3D2D4 F1D4E242 68DDB3F8 1FDA836E 81BE16CD F6B9265B 6FB077E1 18B74777 88085AE6 FF0F6A70 66063BCA 11010B5C 8F659EFF F862AE69 616BFFD3 166CCF45 A00AE278 D70DD2EE 4E048354 3903B3C2 A7672661 D06016F7 4969474D 3E6E77DB AED16A4A D9D65ADC 40DF0B66 37D83BF0 A9BCAE53 DEBB9EC5 47B2CF7F 30B5FFE9 BDBDF21C CABAC28A 53B39330 24B4A3A6 BAD03605 CDD70693 54DE5729 23D967BF B3667A2E C4614AB8 5D681B02 2A6F2B94 B40BBE37 C30C8EA1 5A05DF1B 2D02EF8D"

b_table = a_table.split(' ').map((s) -> return parseInt(s,16))

exp.crc32 = (str) ->
  crc = 0 ^ (-1)
  iTop = str.length
  for i in [0..iTop - 1]
    crc = ( crc >>> 8 ) ^ b_table[( crc ^ str.charCodeAt( i ) ) & 0xFF]
  return (crc ^ (-1)) >>> 0


for k of exp
  if window? and !window[k]
    window[k] = exp[k]
  else if global? and !global[k]
    global[k] = exp[k]


JSON.flatten = (data) ->
  result = {}
  recurse = (cur, prop) ->
    if Object(cur) != cur
      result[prop] = cur
    else if Array.isArray(cur)
      for i in [0..cur.length - 1]
        recurse(cur[i], prop + "[" + i + "]")
      if cur.length == 0
        result[prop] = []
    else
      isEmpty = true
      for p of cur
        isEmpty = false
        recurse(cur[p], (if prop then prop + "." + p else p))
      if isEmpty and prop
        result[prop] = {}
  recurse(data, "")
  return result

JSON.unflatten = (data) ->
  'use strict'
  if Object(data) != data or Array.isArray(data)
    return data
  regex = /\.?([^.\[\]]+)|\[(\d+)\]/g
  resultholder = {}
  for p of data
    cur = resultholder
    prop = ""
    while m = regex.exec(p)
      cur = cur[prop] or (cur[prop] = (if m[2] then [] else {}))
      prop = m[2] or m[1]
    cur[prop] = data[p]
  return resultholder[""] or resultholder

