module.exports = ((schema, options) ->

  if options and options.path?
    path = options.path + '.'
  else
    path = ''

  schema.add(
    address:
      type: String
      label: 'Address'

    city:
      type: String
      trim: true
      label: 'City'

    state:
      type: String
      trim: true
      label: 'State'

    country:
      type: String
      trim: true
      label: 'Country'

    zip:
      type: String
      trim: true
      label: 'Zip or Postal Code'

    email:
      type: String
      unique: true
      index: true
      trim: true
      required: true
      label: 'Email'

    home_email:
      type: String
      unique: true
      index: true
      trim: true
      label: 'Home Email'

    tel:
      type: String
      trim: true
      label: 'Telephone'

    mobile:
      type: String
      trim: true
      label: 'Mobile'

    fax:
      type: String
      trim: true
      label: 'Fax'
  , path)

  if options and options.index.address
    schema.path(path + 'address').index(options.index.address)

  if options and options.index.city
    schema.path(path + 'city').index(options.index.city)

  if options and options.index.state
    schema.path(path + 'state').index(options.index.state)

  if options and options.index.country
    schema.path(path + 'country').index(options.index.country)

  if options and options.index.zip
    schema.path(path + 'zip').index(options.index.zip)

  if options and options.index.email
    schema.path(path + 'email').index(options.index.email)

  if options and options.index.home_email
    schema.path(path + 'home_email').index(options.index.home_email)

  if options and options.index.tel
    schema.path(path + 'tel').index(options.index.tel)

  if options and options.index.mobile
    schema.path(path + 'mobile').index(options.index.mobile)

  schema.virtual(path + 'name.full')
    .get(->
      @get(path + 'name.first') + ' ' + @get(path + 'name.last')
    )
    .set((name) ->
      s = name.split(' ')
      first = s[0]
      last = s[1]
      @set(path + 'name.first', first)
      @set(path + 'name.last', last)
    )
)
