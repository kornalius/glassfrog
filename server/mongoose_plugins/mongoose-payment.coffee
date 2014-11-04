validations = require('composed-validations')
ccValidator = require('cv-credit-card')(validations)

module.exports = ((schema, options) ->

  if options and options.path?
    path = options.path + '.'
  else
    path = ''

  payment = path + 'payment'

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
  , path)

  if options && options.index
    schema.path(payment).index(options.index)

  schema.virtual(payment + '.amount').get( ->
    return (if @get(payment).isTransaction then @get(payment + '.transaction.amount') else 0.00)
  )

  schema.virtual(payment + '.isTransaction').get( ->
      @get(payment + '.transaction.date')?
  )

  schema.virtual(payment + '.isCreditCard').get( ->
    @get(payment + '.kind') in ['Visa', 'Master Card', 'American Express', 'Diners Club']
  )

  schema.virtual(payment + '.isPaypal').get( ->
    @get(payment + '.kind') == 'Paypal'
  )

  schema.virtual(payment + '.isCheck').get( ->
    @get(payment + '.kind') == 'Check'
  )

  schema.virtual(payment + '.isCash').get( ->
    @get(payment + '.kind') == 'Cash'
  )

  schema.virtual(payment + '.isDebit').get( ->
    @get(payment + '.kind') == 'Debit'
  )

  schema.virtual(payment + '.isGoogleWallet').get( ->
    @get(payment + '.kind') == 'Google Wallet'
  )

  schema.virtual(payment + '.isStripe').get( ->
    @get(payment + '.kind') == 'Stripe'
  )

  schema.method(

    obfuscateCreditCard: () ->
      cc = @get(payment + '.number')
      return '****-****-****-' + cc.slice(cc.length - 4, cc.length)

    isValidCreditCardNumber: () ->
      cc = @get(payment + '.number')
      validator = ccValidator({accepts: ['visa_master', 'amex']});
      return validator.test(cc) != false

    displayString: ->
      if @get(payment).isCreditCard()
        "{0} owner: {1} #: {2} exp. date: {3}".format(@get(payment + '.kind').toProperCase(), @get(payment + '.owner'), @obfuscateCreditCard(@get(payment + '.number')), @get(payment + '.date'))
      else if @get(payment).is_paypal()
        "paypal: {0}".format(@get(payment + '.number'))
      else
        ""
  )

)
