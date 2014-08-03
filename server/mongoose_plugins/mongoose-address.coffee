module.exports = ((schema, options) ->
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
  )

  if options && options.index.address
    schema.path('address').index(options.index.address)

  if options && options.index.city
    schema.path('city').index(options.index.city)

  if options && options.index.state
    schema.path('state').index(options.index.state)

  if options && options.index.country
    schema.path('country').index(options.index.country)

  if options && options.index.zip
    schema.path('zip').index(options.index.zip)

  if options && options.index.email
    schema.path('email').index(options.index.email)

  if options && options.index.home_email
    schema.path('home_email').index(options.index.home_email)

  if options && options.index.tel
    schema.path('tel').index(options.index.tel)

  if options && options.index.mobile
    schema.path('mobile').index(options.index.mobile)

  schema.virtual('name.full')
    .get(->
      @name.first + ' ' + @name.last
    )
    .set((name) ->
      s = name.split(' ')
      first = s[0]
      last = s[1]
      @set('name.first', first)
      @set('name.last', last)
    )
)
