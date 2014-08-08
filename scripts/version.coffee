class VersionClass

  major: 0
  minor: 1
  maintenance: 'a'
  build: 0

  constructor: (major, minor, maintenance, build) ->
    if major and major instanceof VersionClass
      @major = major.major
      @minor = major.minor
      @maintenance = major.maintenance
      @build = major.build

    else if major and typeof(major) is 'string'
      @_fromString(major)

    else
      @major = major if major and typeof(major) is 'number'
      @minor = minor if minor and typeof(minor) is 'number'
      @maintenance = maintenance if maintenance and typeof(maintenance) is 'string' and maintenance in ['a', 'b', 'r', 'rc']
      @build = build if build and typeof(build) is 'number'

  _fromString: (s) ->
    m = s.match(/^v?(?:([0-9]+)(?:\.([0-9]+)(?:\.([0-9]+))([abr]|rc)?))$/)
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
    return "{0}.{1}.{2}{3}".format(@major, @minor, @build, @maintenance)

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
    if @major > other.major or @minor > other.minor or @build > other.build
      return 1

    else if @major < other.major or @minor < other.minor or @build < other.build
      return -1

    else
      if @maintenance == 'a'
        if other.maintenance == 'b' or other.maintenance == 'r' or other.maintenance == 'rc'
          return 1
        else if other.maintenance != 'a'
          return -1
        else
          return 0

      else if @maintenance == 'b'
        if other.maintenance == 'r' or other.maintenance == 'rc'
          return 1
        else if other.maintenance != 'b'
          return -1
        else
          return 0

      else if @maintenance == 'r'
        if other.maintenance == 'rc'
          return 1
        else if other.maintenance != 'r'
          return -1
        else
          return 0

      else if @maintenance == 'rc'
        if other.maintenance != 'r'
          return -1
        else
          return 0

      else
        return 0

  @validate: (s) ->
    return /^v?(?:([0-9]+)(?:\.([0-9]+)(?:\.([0-9]+))([abr]|rc)?))$/.test(s)


if define?
  define('VersionClass', [], () ->
    return VersionClass
  )
else
  module.exports = VersionClass
