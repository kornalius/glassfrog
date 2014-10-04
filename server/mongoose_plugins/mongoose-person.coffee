module.exports = ((schema, options) ->
  schema.add(
    name:
      first:
        type: String
        required: true
        trim: true
        label: 'First Name'
        inline: true

      middle:
        type: String
        trim: true
        label: 'Middle Name'
        inline: true

      last:
        type: String
        required: true
        trim: true
        label: 'Last Name'
        inline: true

    gender:
      type: String
      enum: ['', 'M', 'F']
      default: ''
      label: 'Gender'

    timezone:
      type: Number
      default: 0
      label: 'Timezone'

    locale:
      type: String
      default: 'en_us'
      label: 'Locale'
  )

  if options && options.index.gender
    schema.path('gender').index(options.index.gender)

  if options && options.index.timezone
    schema.path('timezone').index(options.index.timezone)

  if options && options.index.locale
    schema.path('locale').index(options.index.locale)

  schema.set('toObject', {virtuals: true})
  schema.set('toJSON', {virtuals: true})

  schema.virtual('name.full').get(->
    @name.first + ' ' + @name.last
  ).set((name) ->
    s = name.split(' ')
    first = null
    middle = null
    last = null
    if s.length
      first = _.str.trim(s[0])
      if s.length >= 3
        middle = _.str.trim(s[1])
      else if s.length >= 2
        last = _.str.trim(s[1])

    if first
      @set('name.first', first)
    if middle
      @set('name.middle', middle)
    if last
      @set('name.last', last)
  )
)
