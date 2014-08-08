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
      if type(input) is 'array'
        return input.join(' ')
      else if type(input) is 'boolean'
        return (if input then 'True' else 'False')
      else if type(input) is 'date'
        return moment(input).format('llll')
      else
        return input
])
