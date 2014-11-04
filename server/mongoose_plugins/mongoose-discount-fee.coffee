module.exports = ((schema, options) ->

  if options and options.path?
    path = options.path + '.'
  else
    path = ''

  discounts_fees = path + 'discounts_fees'

  schema.add(

    discounts_fees: [
      name:
        type: String
        label: 'Discount/Fee Name'

      desc:
        type: String
        label: 'Discount/Fee Description'

      amount:
        type: mongooseCurrency
        label: 'Discount/Fee Amount'

      percent:
        type: Number
        label: 'Discount/Fee Percent'
    ]

  , path)

  schema.virtual(discounts_fees + '.isDiscount').get(->
    amount = @get(discounts_fees + '.amount')
    percent = @get(discounts_fees + '.percent')
    return (amount? and amount < 0) or (percent? and percent < 0)
  )

  schema.virtual(discounts_fees + '.isFee').get(->
    amount = @get(discounts_fees + '.amount')
    percent = @get(discounts_fees + '.percent')
    return (amount? and amount > 0) or (percent? and percent > 0)
  )

  schema.method(

    discount: (r, _amount) ->
      d = 0
      if r.amount?
        d += r.amount
      if r.percent?
        d += _amount * (r.percent / 100)
      return -d

    discounts: (_amount) ->
      a = _amount
      d = 0
      for r in @get(discounts_fees)
        if r.isDiscount
          cd = @discount(r, a)
          if r.compound
            a -= cd
          d += d
      return d

    fee: (r, _amount) ->
      f = 0
      if r.amount?
        f += r.amount
      if r.percent?
        f += _amount * (r.percent / 100)
      return f

    fees: (_amount) ->
      a = _amount
      f = 0
      for r in @get(discounts_fees)
        if r.isFee
          cf = @fee(r, a)
          if r.compound
            a -= cf
          f += cf
      return d

    discountsFees: (_amount) ->
      d = @discounts(_amount)
      f = @fees(d)
      return d + f

  )

)
