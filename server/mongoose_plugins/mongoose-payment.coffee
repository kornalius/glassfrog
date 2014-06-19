validations = require('composed-validations')
ccValidator = require('cv-credit-card')(validations)
Currency = require('mongoose-currency')

payment = ((schema, options) ->
  schema.add(
    payment:
      kind:
        type: String
        enum: ['visa', 'master', 'amex', 'paypal']
        label: 'Payment Type'

      owner:
        type: String
        label: 'Account/Card owner name'

      number:
        type: String
        label: 'Account/Card number'

      date:
        type: Date
        label: 'Expiration date'

      verification:
        type: String
        label: 'Card verification code'

      transaction:
        tid:
          type: String
          label: 'Transaction id'

        date:
          type: Date
          label: 'Transaction date'

        amount:
          type: Currency
          label: 'Transaction Amount'
  )

  if options && options.index
    schema.path('payment').index(options.index)

  schema.virtual('amount').get( ->
    return (if @isTransaction() then @payment.transaction.amount else 0.00)
  )

  schema.method(
    isTransaction: () ->
      return @payment.transaction.date?

    isCreditCard: () ->
      return @payment.kind in ['visa', 'master', 'amex']

    isPaypal: () ->
      return @payment.kind == 'paypal'

    obfuscateCreditCard: () ->
      cc = @payment.number
      return '****-****-****-' + cc.slice(cc.length - 4, cc.length)

    isValidCreditCardNumber: () ->
      cc = @payment.number
      validator = ccValidator({accepts: ['visa_master', 'amex']});
      return validator.test(cc) != false

    displayString: ->
      if @isCreditCard()
        "{0} owner: {1} #: {2} exp. date: {3}".format(@payment.kind.toProperCase(), @payment.owner, @obfuscateCreditCard(@payment.number), @payment.date)
      else if @isPaypal()
        "paypal: {0}".format(@payment.number)
      else
        ""
  )
)

module.exports = payment
