class VersionClass

  major: 0
  minor: 0
  build: 0
  maintenance: 'a'

  constructor: (major, minor, maintenance, build) ->
    if major and major instanceof VersionClass
      @major = major.major
      @minor = major.minor
      @maintenance = major.maintenance
      @build = major.build

    else if major and type(major) is 'string'
      @_fromString(major)

    else
      @major = major if major and typeof(major) is 'number'
      @minor = minor if minor and typeof(minor) is 'number'
      @maintenance = maintenance if maintenance and typeof(maintenance) is 'string' and maintenance in ['a', 'b', 'r', 'rc']
      @build = build if build and typeof(build) is 'number'

  _fromString: (s) ->
    m = s.match(/^v?(?:([0-9]+)(?:\.([0-9]+)(?:\.([0-9]+))([abr]|rc)?))$/)
    if m
      if m.length >= 2
        @major = m[1]
      if m.length >= 3
        @minor = m[2]
      if m.length >= 4
        @build = m[3]
      if m.length >= 5
        @maintenance = m[4]
    return @

  _toString: () ->
    return "{0}.{1}.{2}{3}".format(@major, @minor, @build, (if @maintenance then @maintenance else ''))

  versionString: () ->
    return @_toString()

  newAlpha: () ->
    @minor++
    @maintenance = 'a'
    return @

  newBeta: () ->
    @minor++
    @maintenance = 'b'
    return @

  newReleaseCandidate: () ->
    @minor++
    @maintenance = 'rc'
    return @

  newRelease: () ->
    @major++
    @minor = 0
    @maintenance = 'r'
    return @

  newBuild: () ->
    @build++
    return @

  isAlpha: ()->
    return @maintenance == 'a'

  isBeta: ->
    return @maintenance == 'b'

  isReleaseCandidate: ->
    return @maintenance == 'rc'

  isRelease: ->
    return @maintenance == 'r'

  compareTo: (other) ->

    _compare_maintenance = (maintenance, other_maintenance) ->
      if maintenance == 'a'
        if other_maintenance != 'a'
          return -1
        else
          return 0

      else if maintenance == 'b'
        if other_maintenance == 'r' or other_maintenance == 'rc'
          return -1
        else if other_maintenance != 'b'
          return 1
        else
          return 0

      else if maintenance == 'rc'
        if other_maintenance == 'r'
          return -1
        else if other_maintenance != 'rc'
          return 1
        else
          return 0

      else if maintenance == 'r'
        if other_maintenance != 'r'
          return 1
        else
          return 0

      else
        return 0

    _compare = (value, otherValue) ->
      if value > otherValue
        return 1
      else if value < otherValue
        return -1
      else
        return 0

    maintenance = _compare_maintenance(@maintenance, other.maintenance)
    major = _compare(@major, other.major)
    minor = _compare(@minor, other.minor)
    build = _compare(@build, other.build)

    # Check if =
    if maintenance == 0 and build == 0 and minor == 0 and major == 0
      return 0

    # Check if >
    else if maintenance >= 0 and build >= 0 and minor >= 0 and major >= 0
      return 1

    # Check if <
    else
      return -1


  @validate: (s) ->
    return /^v?(?:([0-9]+)(?:\.([0-9]+)(?:\.([0-9]+))([abr]|rc)?))$/.test(s)


if define?
  define('VersionClass', [], () ->
    return VersionClass
  )
else
  module.exports = VersionClass
