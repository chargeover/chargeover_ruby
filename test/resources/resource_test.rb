require_relative '../test_helper'

class ResourceTest < ChargoverRubyTest

  def test_exists
    Chargeover::Resource
  end

  def test_ignore_unknown_attributes
    assert Chargeover::Resource.new({'does_not_exist' => 'some value'})
  end

end