require_relative '../test_helper'

class TokenizedCardTest < ChargoverRubyTest
  def test_exists
    assert Chargeover::TokenizedCard
  end

  def test_should_create_a_tokenized_card
    VCR.use_cassette('create_tokenized_card', :match_requests_on => [:anonymized_uri]) do
      customer = Chargeover::Customer.find(35)
      tokenized_card = Chargeover::TokenizedCard.create(
          customer_id: customer.customer_id,
          type: 'customer',
          token: 'cus_1CoGUjtUMyLIDR'
      )
      assert tokenized_card
    end
  end

  def test_should_return_tokenized_cards_for_customer
    VCR.use_cassette('tokenized_cards_by_customer', :match_requests_on => [:anonymized_uri]) do
      customer = Chargeover::Customer.find(51)
      tokenized_cards = Chargeover::TokenizedCard.find_all_by_customer_id(customer.customer_id)
      assert_equal 1, tokenized_cards.length
      assert Chargeover::TokenizedCard, tokenized_cards.first.class
    end
  end
end
