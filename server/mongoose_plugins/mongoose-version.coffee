version = ((schema, options) ->
  schema.add(
    version:
      major:
        type: Number
        default: 0
      minor:
        type: Number
        default: 0
      maintenance:
        type: String
        default: 'a'
      build:
        type: Number
        default: 0
      date:
        type: Date
      notes:
        type: String
  )

  if options && options.index
    schema.path('version').index(options.index)

  schema.pre('save', (next) ->
    @version.build += 1
    next()
  )

  schema.method(
    displayString: ->
      "v{0}.{1}.{2}{3}".format(@version.major, @version.minor, @version.build, @version.maintenance)
#      "{0}.{1}.{2}-{3}".format(@version.major, @version.minor, @version.maintenance, @version.build)

    alpha: (notes) ->
      @version.minor += 1
      @version.maintenance = 'a'
      @version.date = new Date
      @version.notes = notes
      @save()

    beta: (notes) ->
      @version.minor += 1
      @version.maintenance = 'b'
      @version.date = new Date
      @version.notes = notes
      @save()

    releaseCandidate: (notes) ->
      @version.minor += 1
      @version.maintenance = 'rc'
      @version.date = new Date
      @version.notes = notes
      @save()

    release: (notes) ->
      @version.major += 1
      @version.minor = 0
      @version.maintenance = 'r'
      @version.date = new Date
      @version.notes = notes
      @save()

    isAlpha: ->
      @version.maintenance == 'a'

    isBeta: ->
      @version.maintenance == 'b'

    isReleaseCandidate: ->
      @version.maintenance == 'rc'

    isRelease: ->
      @version.maintenance == 'r'
  )
)

module.exports = version
