module.exports = ((schema, options) ->
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

  )

  schema.set('toObject', {virtuals: true})
  schema.set('toJSON', {virtuals: true})

  schema.virtual('discounts_fees.isDiscount').get(->
    return (@amount? and @amount < 0) or (@percent? and @percent < 0)
  )

  schema.virtual('discounts_fees.isFee').get(->
    return (@amount? and @amount > 0) or (@percent? and @percent > 0)
  )

  schema.method(

    discount: (r, amount) ->
      d = 0
      if r.amount?
        d += r.amount
      if r.percent?
        d += amount * (r.percent / 100)
      return -d

    discounts: (amount) ->
      a = amount
      d = 0
      for r in @discounts_fees
        if r.isDiscount
          cd = @discount(r, a)
          if r.compound
            a -= cd
          d += d
      return d

    fee: (r, amount) ->
      f = 0
      if r.amount?
        f += r.amount
      if r.percent?
        f += amount * (r.percent / 100)
      return f

    fees: (amount) ->
      a = amount
      f = 0
      for r in @discounts_fees
        if r.isFee
          cf = @fee(r, a)
          if r.compound
            a -= cf
          f += cf
      return d

    discountsFees: (amount) ->
      d = @discounts(amount)
      f = @fees(d)
      return d + f

  )

)
