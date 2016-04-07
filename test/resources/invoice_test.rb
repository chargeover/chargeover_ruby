require_relative '../test_helper'

class InvoiceTest < ChargoverRubyTest

  def test_exists
    assert Chargeover::Invoice
  end

  def test_should_find_and_invoice_by_id
    VCR.use_cassette('one_invoice', :match_requests_on => [:anonymized_uri]) do

      invoice = Chargeover::Invoice.find(10000)
      assert_equal Chargeover::Invoice, invoice.class

      assert_equal 'https://imagerelay-staging.chargeover.com/r/invoice/pdf/lfthab4s5rgz', invoice.url_pdflink

    end
  end

  def test_should_void_an_invoice
    VCR.use_cassette('void_invoice', :match_requests_on => [:anonymized_uri]) do
      invoice = Chargeover::Invoice.find(10016)
      assert invoice.void
      invoice = Chargeover::Invoice.find(10016)
      assert invoice.void_datetime
    end
  end

  def test_should_email_an_invoice
    VCR.use_cassette('send_invoice', :match_requests_on => [:anonymized_uri]) do
      invoice = Chargeover::Invoice.find(10016)
      assert invoice.send_email
    end
  end

  def test_query_interface
    VCR.use_cassette('query_invoices', :match_requests_on => [:anonymized_uri]) do
      options = [
        { field: 'invoice_status_str', operator: 'EQUALS', value: 'open-overdue' }
      ]
      invoices = Chargeover::Invoice.query(options, 0, 100, 'invoice_id:ASC')
      assert_equal 9, invoices.length

      invoices.each do |invoice|
        assert_equal 'open-overdue', invoice.invoice_status_str
        assert invoice.balance > 0
      end
    end
  end

  def test_should_return_customer
    VCR.use_cassette('invoice_customer', :match_requests_on => [:anonymized_uri]) do
      invoice = Chargeover::Invoice.find(10116)
      assert_equal Chargeover::Customer, invoice.customer.class
      assert_equal 'Test Customer', invoice.customer.company
    end
  end

  def test_should_return_recurring_package
    VCR.use_cassette('invoice_recurring_package_present', :match_requests_on => [:anonymized_uri]) do
      invoice = Chargeover::Invoice.find(10104)
      assert_equal Chargeover::RecurringPackage, invoice.recurring_package.class
      assert_equal invoice.package_id, invoice.recurring_package.package_id
    end
  end

  def test_should_not_return_a_recurring_package
    VCR.use_cassette('invoice_recurring_package_not_present', :match_requests_on => [:anonymized_uri]) do
      invoice = Chargeover::Invoice.find(10118)
      assert_nil invoice.recurring_package
    end
  end

  def test_should_attempt_payment
    VCR.use_cassette('invoice_attempt_payment', :match_requests_on => [:anonymized_uri]) do
      invoice = Chargeover::Invoice.find(10088)
      transaction = invoice.attempt_payment
      assert_equal 1259.28, transaction.amount
      invoice = Chargeover::Invoice.find(10088)
      assert_equal 0, invoice.balance
    end
  end

  def test_should_attempt_payment_with_amount
    VCR.use_cassette('invoice_attempt_payment_with_amount', :match_requests_on => [:anonymized_uri]) do
      invoice = Chargeover::Invoice.find(10115)
      assert_equal 314.82, invoice.balance
      transaction = invoice.attempt_payment(100.00)
      assert_equal 100, transaction.amount
      invoice = Chargeover::Invoice.find(10115)
      assert_equal 214.82, invoice.balance
    end
  end

end