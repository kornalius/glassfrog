'use strict'

### Filters ###

angular.module('app.filters', [])

.filter('interpolate', [
  'version',

  (version) ->
    (text) ->
      String(text).replace(/\%VERSION\%/mg, version)
])

.filter('string', [

  () ->
    (input) ->
      t = type(input)
      if t is 'array'
        return input.join(',')
      else if t is 'boolean'
        return (if input then 'true' else 'false')
      else if t is 'moment'
        return input.format('L LT')
      else if t is 'date'
        return moment(input).format('L LT')
      else if t is 'tinycolor'
        return input.toHex8String()
      else if t is 'regexp'
        return input.toString()
      else if t is 'function'
        return input.toString()
      else if t is 'number'
        if input == Number.NaN
          return '0'
        else
          return input.toString()
      else
        return input
])

.filter('partition', [
  '$cacheFactory'

  ($cacheFactory) ->
    arrayCache = $cacheFactory('partition')
    filter = (arr, size) ->
      if !arr
        return
      newArr = []
      for i in [0..arr.length] by size
        newArr.push(arr.slice(i, i + size))
      arrString = jsonToString(arr)
      cachedParts = arrayCache.get(arrString + size)
      if jsonToString(cachedParts) == jsonToString(newArr)
        return cachedParts
      arrayCache.put(arrString + size, newArr)
      return newArr
    return filter
])
