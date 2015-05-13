require_relative '../test_helper'

class TransactionTest < ChargoverRubyTest
  def test_exists
    assert Chargeover::Transaction
  end

  def test_should_return_all_transactions
    VCR.use_cassette('list_transactions', :match_requests_on => [:anonymized_uri]) do
      transactions = Chargeover::Transaction.all
      assert Chargeover::Transaction, transactions.first.class
      assert 5, transactions.length
    end
  end

  def test_should_return_information_on_credit
    VCR.use_cassette('one_credit', :match_requests_on => [:anonymized_uri]) do
      transaction = Chargeover::Transaction.find(79)
      assert Chargeover::Transaction, transaction.class
      assert 'crd', 'transaction_type'
    end
  end


  def test_should_create_a_credit
    VCR.use_cassette('create_one_credit', :match_requests_on => [:anonymized_uri]) do
      transaction = Chargeover::Transaction.create(
          customer_id: 18,
          transaction_type: 'cre',
          gateway_method: 'credit',
          amount: '42.50',
          gateway_status: 1,
          gateway_transid: 'API Credit',
          transaction_detail: 'Credit for unused Image Relay Small'
      )
      assert Chargeover::Transaction, transaction.class
      assert 'crd', 'transaction_type'
      assert_equal 42.50, transaction.amount
    end
  end

  def test_should_create_a_credit_and_apply_to_invoice
    VCR.use_cassette('create_and_apply_credit', :match_requests_on => [:anonymized_uri]) do
      invoice = Chargeover::Invoice.find(10027)
      assert_equal 500.00, invoice.balance
      transaction = Chargeover::Transaction.create(
          customer_id: 18,
          transaction_type: 'cre',
          gateway_method: 'credit',
          amount: '42.50',
          gateway_status: 1,
          gateway_transid: 'API Credit',
          transaction_detail: 'Credit for unused Image Relay Small',
          applied_to: [{
            invoice_id: 10027
          }]
      )
      assert Chargeover::Transaction, transaction.class
      assert 'crd', 'transaction_type'
      assert_equal 42.50, transaction.amount

      invoice = Chargeover::Invoice.find(10027)
      assert_equal 500.00 - 42.50, invoice.balance
    end
  end

  def test_should_create_a_check_payment_and_apply_to_invoice
    VCR.use_cassette('create_and_apply_payment', :match_requests_on => [:anonymized_uri]) do
      invoice = Chargeover::Invoice.find(10041)
      assert_equal 4500.00, invoice.balance
      transaction = Chargeover::Transaction.create(
          customer_id: 33,
          transaction_type: 'pay',
          gateway_method: 'check',
          amount: '4500.00',
          gateway_status: 1,
          gateway_transid: 'Manual Entry',
          transaction_detail: 'Payment for Services',
          applied_to: [{
                           invoice_id: 10041
                       }]
      )
      assert Chargeover::Transaction, transaction.class
      assert 'pay', 'transaction_type'
      assert_equal 4500.00, transaction.amount

      invoice = Chargeover::Invoice.find(10041)
      assert_equal 0, invoice.balance
    end
  end

  def test_should_refund_a_payment_via_a_tokenized_card
    VCR.use_cassette('refund_tokenized_payment', :match_requests_on => [:anonymized_uri]) do
      transaction = Chargeover::Transaction.find(145)
      assert_equal 104.94, transaction.amount
      refund = transaction.refund
      assert_equal 'ref', refund.transaction_type
      assert_equal -104.94, refund.amount
    end
  end

  def test_should_refund_a_transaction_without_amount
    VCR.use_cassette('refund_cc_payment_full_amount', :match_requests_on => [:anonymized_uri]) do
      transaction = Chargeover::Transaction.find(128)
      assert_equal 99.00, transaction.amount
      refund = transaction.refund
      assert_equal 'ref', refund.transaction_type
      assert_equal -99.00, refund.amount
    end
  end

  def test_should_refund_a_transaction_with_amount
    VCR.use_cassette('refund_cc_payment_partial_amount', :match_requests_on => [:anonymized_uri]) do
      transaction = Chargeover::Transaction.find(131)
      assert_equal 99.00, transaction.amount
      refund = transaction.refund(10.00)
      assert_equal 'ref', refund.transaction_type
      assert_equal -10.00, refund.amount
    end
  end

  def test_should_attempt_payment_of_an_invoice
    VCR.use_cassette('attempt_payment_of_invoice', :match_requests_on => [:anonymized_uri]) do
      transaction = Chargeover::Transaction.attempt_payment(35, [ '10064' ])
      assert_equal 4500, transaction.amount
    end
  end

  def test_should_attempt_payment_of_an_invoice_and_fail
    VCR.use_cassette('attempt_failure_of_invoice', :match_requests_on => [:anonymized_uri]) do
      assert_raises(Chargeover::ChargeoverException) do
        Chargeover::Transaction.attempt_payment(34, [ '10063' ])
      end
    end
  end

end