require_relative '../test_helper'

class ContactTest < ChargoverRubyTest
  def test_exists
    assert Chargeover::Contact
  end

  def test_should_return_a_contact
    VCR.use_cassette('one_contact', :match_requests_on => [:anonymized_uri]) do
      contact = Chargeover::Contact.find(394)
      assert_equal Chargeover::Contact, contact.class

      assert_equal 1, contact.customers.length
      assert_equal 44, contact.customers.first.customer_id
    end
  end

  def test_should_create_a_contact
    VCR.use_cassette('create_contact', :match_requests_on => [:anonymized_uri]) do
      contact = Chargeover::Contact.create(
                                       first_name: 'John',
                                       last_name: 'Doe',
                                       email: 'jd@example.com',
                                       customer_id: 44
      )
      assert_equal Chargeover::Contact, contact.class

      assert_equal 'jd@example.com', contact.email
      assert_equal 'John', contact.first_name
      assert_equal 'Doe', contact.last_name
    end
  end

  def test_should_return_all_contacts
    VCR.use_cassette('all_contacts', :match_requests_on => [:anonymized_uri]) do
      contacts = Chargeover::Contact.all
      assert_equal 49, contacts.length
      contacts.each do |contact|
        if contact.user_id.to_s == '394'
          assert 1, contact.customers.length
        end
      end
    end
  end

  def test_should_destroy_a_contact
    VCR.use_cassette('destroy_contact', :match_requests_on => [:anonymized_uri]) do
      contact = Chargeover::Contact.find(396)
      Chargeover::Contact.destroy(contact.user_id)
      assert_raises(Chargeover::ChargeoverException) do
        Chargeover::Contact.find(396)
      end
    end
  end

  def test_should_return_true_if_contact_belongs_to_customer
    VCR.use_cassette('has_contact_true', :match_requests_on => [:anonymized_uri]) do
      contact = Chargeover::Contact.find(395)
      assert contact.has_customer?(44)
    end
  end

  def test_should_update_contact_for_customer
    VCR.use_cassette('updates_contact', :match_requests_on => [:anonymized_uri]) do
      contact = Chargeover::Contact.find(398)
      assert_equal 'Jane Smith', contact.name
      assert_equal 'jane@example.com', contact.email
      contact = contact.update_attributes(name: 'Jane Doe', email: 'j@example.com')
      assert_equal 'Jane Doe', contact.name
      assert_equal 'j@example.com', contact.email
    end
  end
end
