require_relative '../test_helper'

class ContactTest < ChargoverRubyTest
  def test_contact_exists
    assert Chargeover::CreditCard
  end

  def test_should_return_all_credit_cards_for_customer
    VCR.use_cassette('customer_credit_cards', :match_requests_on => [:anonymized_uri]) do
      cards = Chargeover::CreditCard.find_all_by_customer_id(44)
      assert 1, cards.length
      assert_equal Chargeover::CreditCard, cards.first.class
    end
  end

  def test_should_destroy_a_credit_card
    VCR.use_cassette('destroy_card', :match_requests_on => [:anonymized_uri]) do
      cards = Chargeover::CreditCard.find_all_by_customer_id(44)
      card = cards.first
      #assert_nothing_raised do
        Chargeover::CreditCard.destroy(card.creditcard_id)
      #end
    end
  end

end
