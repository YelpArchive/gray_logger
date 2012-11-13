require 'test_helper'
class SupportTest < Test::Unit::TestCase

  class SupportedClass
    include GrayLogger::Support
  end

  def test_symbolize_keys_returns_a_hash_with_symbolized_keys
    hash = {
      "not_a_symbol" => 'something',
      :a_symbol => 'something else'
    }
    new_hash = SupportedClass.send(:symbolize_keys, hash)
    assert_equal 'something', new_hash[:not_a_symbol], "not_a_symbol should be a symbol: #{new_hash.inspect}"
    assert_equal 'something else', new_hash[:a_symbol], "a_symbol should be a symbol: #{new_hash.inspect}"
  end


end
