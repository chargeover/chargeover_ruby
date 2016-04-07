require_relative '../test_helper'

class ResourceTest < ChargoverRubyTest

  def test_exists
    Chargeover::Resource
  end

  def test_ignore_unknown_attributes
    assert Chargeover::Resource.new({'does_not_exist' => 'some value'})
  end

  def test_build_query_string
    options = [
        { field: :customer_id, operator: 'EQUALS', value: '22' },
        { field: 'field_2', operator: :lt, value: 'test' }
    ]

    url = Chargeover::Customer.send(:build_query, options, 0, 100, 'customer_id:ASC')

    assert_equal 'https://imagerelay-staging.chargeover.com/api/v3/customer?where=customer_id:EQUALS:22,field_2:LT:test&order=customer_id:ASC&limit=100&offset=0', url
  end

end