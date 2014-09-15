angular.module('user.invoices', ['dynamicForm'])

.controller('UserInvoicesCtrl', [
  '$scope'
  '$rootScope'
  'dynForm'
  'Rest'

($scope, $rootScope, dynForm, Rest) ->

  $scope.invoice = new Rest('invoice')

  $scope.invoice.fetch(1, ->
    invoicesTable =
      label: 'Invoices'
      name: "invoicesTable"
      editMode: 'none'
      canMove: false
      layout: {type:'table'}

      fields: [
        label: "#"
        description: "invoice #"
        fieldname: 'invoiceNo'
      ,
        label: "Date"
        type: "input"
        description: "Invoice date"
        fieldname: 'created_at'
        date: true
      ,
        label: "Plan"
        type: "input"
        description: "Invoice plan"
        fieldname: 'plan.name'
      ,
        label: "Payment"
        type: "input"
        description: "Payment type"
        fieldname: 'payment.kind'
      ,
        label: "Card/Account #"
        type: "input"
        description: "Credit card or account #"
        fieldname: 'payment.number'
      ,
        label: "Exp. Date"
        type: "input"
        date: true
        description: "Credit card expiration date"
        fieldname: 'payment.date'
      ,
        label: "Transaction #"
        type: "input"
        description: "Payment transaction #"
        fieldname: 'payment.transaction.tid'
      ,
        label: "Amount"
        type: "input"
        description: "Invoice amount"
        fieldname: 'amount'
        currency: true
      ]

    dynForm.build($scope, invoicesTable, $scope.invoices, '#invoices')
  )

])
