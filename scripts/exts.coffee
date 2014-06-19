if !String.prototype.toProperCase
  String.prototype.toProperCase = ->
    return @replace(/\w\S*/g, (txt) ->
      return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase()
    )

if !String.prototype.format
  String.prototype.format = () ->
    args = arguments
    return @replace(/{(\d+)}/g, (match, number) ->
      return if typeof args[number] != 'undefined' then args[number] else match
    )

if !String.prototype.startsWith
  String.prototype.startsWith = (searchString, position) ->
    position = if position? then position else 0
    return @indexOf(searchString, position) == position

if !String.prototype.endsWith
  String.prototype.endsWith = (searchString, position) ->
    position = if position? then position else (@length - searchString.length)
    return @indexOf(searchString, position) == position

if !String.prototype.humanize
  String.prototype.humanize = () ->
    return @replace(/[_-]/g, ' ').toProperCase()

if !Array.prototype.diff
  Array.prototype.diff = (a) ->
    return @filter((i) ->
      return a.indexOf(i) < 0
    )
