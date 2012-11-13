require 'test_helper'
class MessageTest < Test::Unit::TestCase

  def test_ensures_that_short_message_field_is_set
    message = GrayLogger::Message.new({})
    assert !message.to_hash["short_message"].nil?, "short message isn't set: #{message.to_hash.inspect}"
  end

  def test_prefixes_non_reserved_keys_with_underscores
    message = GrayLogger::Message.new({:my_custom_field => 'my custom message'})
    assert !message.to_hash["_my_custom_field"].nil?, "_my_custom_field isn't set: #{message.to_hash.inspect}"
    assert message.to_hash["my_custom_field"].nil?, "my_custom_field is set: #{message.to_hash.inspect}"
  end


end
