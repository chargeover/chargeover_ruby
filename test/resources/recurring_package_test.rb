require_relative '../test_helper'

class RecurringPackageTest < ChargoverRubyTest
  def test_exists
    assert Chargeover::RecurringPackage
  end

  def test_should_list_recurring_packages
    VCR.use_cassette('list_packages', :match_requests_on => [:anonymized_uri]) do
      packages = Chargeover::RecurringPackage.all

      assert_equal Chargeover::RecurringPackage, packages.first.class
      assert_equal 29, packages.length
    end
  end

  def test_should_return_a_recurring_package_by_id
    VCR.use_cassette('one_recurring_package', :match_requests_on => [:anonymized_uri]) do
      package = Chargeover::RecurringPackage.find(554)

      assert_equal Chargeover::RecurringPackage, package.class
    end
  end

  def test_should_return_package_line_items
    VCR.use_cassette('one_recurring_package_with_items', :match_requests_on => [:anonymized_uri]) do
      package = Chargeover::RecurringPackage.find(555)

      assert_equal 1, package.line_items.length
      assert_equal Chargeover::LineItem, package.line_items.first.class
      assert_equal Chargeover::Item, package.line_items.first.item.class
    end
  end

  def test_should_return_credit_card_details
    VCR.use_cassette('recurring_package_with_credit_card', :match_requests_on => [:anonymized_uri]) do
      package = Chargeover::RecurringPackage.find(566)

      assert_equal Chargeover::CreditCard, package.credit_card.class
    end
  end

  def test_should_upgrade_a_package
    VCR.use_cassette('upgrade_a_package', :match_requests_on => [:anonymized_uri]) do
      package = Chargeover::RecurringPackage.find(592)
      line_item = package.line_items.first
      assert_equal 500.00, line_item.tierset.base
      new_item = Chargeover::Item.find_by_external_key('super')
      updated_package = package.upgrade(line_item.line_item_id, new_item.item_id)
      assert_equal Chargeover::RecurringPackage, updated_package.class
      assert_equal new_item.item_id, updated_package.line_items.first.item_id
    end
  end

  def test_should_update_next_invoice_date
    VCR.use_cassette('update_package_invoice_date', :match_requests_on => [:anonymized_uri]) do
      package = Chargeover::RecurringPackage.find(555)
      assert DateTime.parse('2015-03-24') != package.next_invoice_datetime
      updated_package = package.update_hold_date('2015-03-26')
      assert_equal DateTime.parse('2015-03-26'), updated_package.next_invoice_datetime
    end
  end

  def test_should_update_package_payment_method
    VCR.use_cassette('update_package_payment_method', :match_requests_on => [:anonymized_uri]) do
      package = Chargeover::RecurringPackage.find(555)
      assert_equal 'crd', package.paymethod
      updated_package = package.update_paymethod('inv')
      assert_equal 'inv', updated_package.paymethod
    end
  end

  def test_should_update_package_paycycle
    VCR.use_cassette('update_package_payment_cycle', :match_requests_on => [:anonymized_uri]) do
      package = Chargeover::RecurringPackage.find(555)
      assert_equal 'qtr', package.paycycle
      updated_package = package.update_paycycle('mon')
      assert_equal 'mon', updated_package.paycycle
    end
  end

  def test_should_cancel_a_recurring_package
    VCR.use_cassette('cancel_package', :match_requests_on => [:anonymized_uri]) do
      package = Chargeover::RecurringPackage.find(571)
      assert package.cancel
      canceled_package = Chargeover::RecurringPackage.find(571)
      assert canceled_package.cancel_datetime
    end
  end

  def test_should_return_latest_invoice
    VCR.use_cassette('package_latest_invoice', :match_requests_on => [:anonymized_uri]) do
      package = Chargeover::RecurringPackage.find(571)
      invoice = package.latest_invoice
      assert Chargeover::Invoice, invoice.class
      assert 571, invoice.package_id
    end
  end

  def test_should_change_the_amount_of_a_line_item
    VCR.use_cassette('update_package_line_item', :match_requests_on => [:anonymized_uri]) do
      package = Chargeover::RecurringPackage.find(592)
      line_item = package.find_line_item_by_item_external_key('additional_bandwidth')
      assert_equal Chargeover::LineItem, line_item.class
      assert_equal 50, line_item.tierset.base
      assert_equal Chargeover::LineItem, line_item.class
      package.change_line_item_price(line_item, 200)
      package = Chargeover::RecurringPackage.find(592)
      line_item = package.find_line_item_by_item_external_key('additional_bandwidth')
      assert_equal 200, line_item.tierset.base
    end
  end

  def test_should_add_line_item_to_package
    VCR.use_cassette('add_line_item', :match_requests_on => [:anonymized_uri]) do
      package = Chargeover::RecurringPackage.find(592)
      assert_equal 2, package.line_items.length
      new_item = Chargeover::Item.find_by_external_key('additional_storage')
      package.add_line_item(new_item, 800)
      package = Chargeover::RecurringPackage.find(592)
      line_item = package.find_line_item_by_item_external_key('additional_storage')
      assert_equal 800, line_item.tierset.base
    end
  end

  def test_should_update_custom_value
    VCR.use_cassette('update_custom_1', :match_requests_on => [:anonymized_uri]) do
      package = Chargeover::RecurringPackage.find(640)
      assert_equal '888888', package.custom_1
      package = package.update_custom_1('123456')
      assert_equal '123456', package.custom_1
    end
  end

  def test_should_update_payment_terms
    VCR.use_cassette('update_terms_id', :match_requests_on => [:anonymized_uri]) do
      package = Chargeover::RecurringPackage.find(640)
      assert_equal 3, package.terms_id
      package = package.update_payment_terms(2)
      assert_equal 2, package.terms_id
    end
  end

  def test_should_update_attributes
    VCR.use_cassette('update_package_attributes', :match_requests_on => [:anonymized_uri]) do
      package = Chargeover::RecurringPackage.find(640)
      assert_equal 2, package.terms_id
      assert_equal '123456', package.custom_1
      package = package.update_attributes(
                           custom_1: '777777',
                           terms_id: 3
      )
      assert_equal 3, package.terms_id
      assert_equal '777777', package.custom_1
    end
  end

end