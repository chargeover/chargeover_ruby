require_relative '../test_helper'

class CustomerTest < ChargoverRubyTest
  def test_exists
    assert Chargeover::Customer
  end

  def test_returns_a_single_customer_object
    VCR.use_cassette('one_customer', :match_requests_on => [:anonymized_uri]) do
      customer = Chargeover::Customer.find(1)
      assert_equal Chargeover::Customer, customer.class

      # Check that the fields are accessible by our model
      assert_equal 1, customer.customer_id
      assert_equal 348, customer.superuser_id
      assert_nil customer.external_key
      assert_equal 'Test Customer', customer.company
      assert_equal '123 Main Street', customer.bill_addr1
      assert_equal 'Suite 42', customer.bill_addr2
      assert_nil customer.bill_addr3
      assert_equal 'Burlington', customer.bill_city
      assert_equal 'VT', customer.bill_state
      assert_equal '05401', customer.bill_postcode
      assert_equal 'United States', customer.bill_country
      assert_nil customer.bill_notes
      assert_equal '70.88.244.230', customer.write_ipaddr
      assert_equal '70.88.244.230', customer.mod_ipaddr
      assert_nil customer.ship_addr1
      assert_nil customer.ship_addr2
      assert_nil customer.ship_addr3
      assert_nil customer.ship_city
      assert_nil customer.ship_state
      assert_nil customer.ship_postcode
      assert_nil customer.ship_country
      assert_nil customer.ship_notes
      assert_equal DateTime.parse("2015-03-18T11:58:28+00:00"), customer.mod_datetime
      assert_equal DateTime.parse("2015-03-18T11:58:28+00:00"), customer.write_datetime
      assert_empty customer.ship_block
      assert_equal "123 Main Street\nSuite 42\nBurlington VT 05401\nUnited States", customer.bill_block
      assert_nil customer.custom_1
      assert_nil customer.custom_2
      assert_nil customer.custom_3
      assert_equal 'test@example.com', customer.superuser_email
      assert_equal 'Test', customer.superuser_first_name
      assert_equal 'Customer', customer.superuser_last_name
    end
  end

  def test_returns_a_list_of_customers
    VCR.use_cassette('customer_list', :match_requests_on => [:anonymized_uri]) do
      customers = Chargeover::Customer.all
      assert_respond_to customers, :length
      assert_respond_to customers, :each
      assert_equal 5, customers.length
      assert_equal Chargeover::Customer, customers.first.class
    end
  end

  def test_should_create_a_customer
    VCR.use_cassette('new_customer', :match_requests_on => [:anonymized_uri]) do
      customer = Chargeover::Customer.create(
                                       :external_key => 'mycustomer_id',
                                       :company => 'Another Customer',
                                       :superuser_email => 'customer@example.com',
                                       :superuser_first_name => 'John',
                                       :superuser_last_name => 'Smith',
                                       :bill_addr1 => '555 Main Street',
                                       :bill_addr2 => 'Suite 86',
                                       :bill_state => 'Vermont',
                                       :bill_postcode => '05401',
                                       :bill_country => 'United States',
                                       :custom_1 => '123456'
               )
      assert_equal Chargeover::Customer, customer.class

      assert customer.customer_id
      assert_equal 'mycustomer_id', customer.external_key
      assert_equal 'Another Customer', customer.company
      assert_equal 'customer@example.com', customer.superuser_email
      assert_equal 'John', customer.superuser_first_name
      assert_equal 'Smith', customer.superuser_last_name
      assert_equal '555 Main Street', customer.bill_addr1
      assert_equal 'Suite 86', customer.bill_addr2
      assert_equal 'Vermont', customer.bill_state
      assert_equal '05401', customer.bill_postcode
      assert_equal 'United States', customer.bill_country
      assert_equal '123456', customer.custom_1
    end
  end

  def test_should_return_the_most_recent_invoice_for_a_customer
    VCR.use_cassette('latest_invoice', :match_requests_on => [:anonymized_uri]) do
      customer = Chargeover::Customer.find(39)
      invoice = customer.latest_invoice
      assert_equal Chargeover::Invoice, invoice.class
    end
  end

  def test_should_update_an_existing_customer
    VCR.use_cassette('update_customer', :match_requests_on => [:anonymized_uri]) do
      customer = Chargeover::Customer.find(1)

      assert customer.update_attributes(
                  company: 'Updated Company Name',
                  superuser_email: 'newemail@example.com',
                  superuser_first_name: 'Todd',
                  bill_addr1: 'New Street',
                  bill_state: 'MA',
                  bill_city: 'Mashpee'
      )

      assert_equal 'Updated Company Name', customer.company
      assert_equal 'newemail@example.com', customer.superuser_email
      assert_equal 348, customer.superuser_id
      assert_equal 'Todd', customer.superuser_first_name
      assert_equal 'New Street', customer.bill_addr1
      assert_equal 'MA', customer.bill_state
      assert_equal 'Mashpee', customer.bill_city
    end
  end

  def test_should_delete_a_customer
    VCR.use_cassette('delete_customer', :match_requests_on => [:anonymized_uri]) do
      assert Chargeover::Customer.destroy(3)

      exception = assert_raises(Chargeover::ChargeoverException) do
        Chargeover::Customer.find(3)
      end

      assert_equal 404, exception.status
    end
  end

  def test_should_fail_to_find_a_user_that_does_not_exist
    VCR.use_cassette('missing_customer', :match_requests_on => [:anonymized_uri]) do
      exception = assert_raises(Chargeover::ChargeoverException) do
        Chargeover::Customer.find(99)
      end
      assert_equal 404, exception.status
    end
  end

  def test_should_fail_to_create_a_customer_with_missing_params
    VCR.use_cassette('fail_to_create_customer', :match_requests_on => [:anonymized_uri]) do
      exception = assert_raises(Chargeover::ChargeoverException) do
        Chargeover::Customer.create({})
      end
      assert_equal 400, exception.status
    end
  end

  def test_should_return_recurring_packages_for_customer
    VCR.use_cassette('customer_with_packages', :match_requests_on => [:anonymized_uri]) do
      customer = Chargeover::Customer.find(4)
      assert_equal Array, customer.recurring_packages.class
      assert_equal 1, customer.recurring_packages.length
      assert_equal Chargeover::RecurringPackage, customer.recurring_packages.first.class
    end
  end

  def test_should_find_customer_by_external_key
    VCR.use_cassette('customer_by_key', :match_requests_on => [:anonymized_uri]) do
      customer = Chargeover::Customer.find_by_external_key('23')
      assert_equal Chargeover::Customer, customer.class
    end
  end

  def test_should_return_all_invoices_for_customer
    VCR.use_cassette('customer_with_invoices', :match_requests_on => [:anonymized_uri]) do
      customer = Chargeover::Customer.find(1)

      assert_equal 2, customer.invoices.length
      assert_equal Chargeover::Invoice, customer.invoices.first.class
    end
  end

  def test_should_return_all_contacts_for_customer
    VCR.use_cassette('customer_with_contacts', :match_requests_on => [:anonymized_uri]) do
      customer = Chargeover::Customer.find(44)

      contacts = customer.contacts
      assert_equal 2, contacts.length
      assert_equal Chargeover::Contact, contacts.first.class
    end
  end


end