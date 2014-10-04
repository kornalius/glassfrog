validations = require('composed-validations')
ccValidator = require('cv-credit-card')(validations)

module.exports = ((schema, options) ->
  schema.add(
    payment:
      kind:
        type: String
        enum: ['Visa', 'Master Card', 'American Express', 'Diners Club', 'Paypal', 'Check', 'Cash', 'ACH', 'Bank Transfer', 'Credit', 'Debit', 'Google Wallet', 'Stripe']
        label: 'Payment Type'

      owner:
        type: String
        label: 'Account/Card owner name'
        private: true

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
          readOnly: true

        date:
          type: Date
          label: 'Transaction date'
          readOnly: true

        amount:
          type: mongooseCurrency
          label: 'Transaction Amount'
          readOnly: true
          private: true
  )

  if options && options.index
    schema.path('payment').index(options.index)

  schema.set('toObject', {virtuals: true})
  schema.set('toJSON', {virtuals: true})

  schema.virtual('amount').get( ->
    return (if @isTransaction then @payment.transaction.amount else 0.00)
  )

  schema.virtual('isTransaction').get( ->
      @payment.transaction.date?
  )

  schema.virtual('isCreditCard').get( ->
    @payment.kind in ['Visa', 'Master Card', 'American Express', 'Diners Club']
  )

  schema.virtual('isPaypal').get( ->
    @payment.kind == 'Paypal'
  )

  schema.virtual('isCheck').get( ->
    @payment.kind == 'Check'
  )

  schema.virtual('isCash').get( ->
    @payment.kind == 'Cash'
  )

  schema.virtual('isDebit').get( ->
    @payment.kind == 'Debit'
  )

  schema.virtual('isGoogleWallet').get( ->
    @payment.kind == 'Google Wallet'
  )

  schema.virtual('isStripe').get( ->
    @payment.kind == 'Stripe'
  )

  schema.method(

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
      else if @is_paypal()
        "paypal: {0}".format(@payment.number)
      else
        ""
  )

)
