require 'test_helper'
class MessageTest < MiniTest::Unit::TestCase

  def test_message_must_respond_to_to_hash
    assert GrayLogger::Message.new.respond_to?(:to_hash), "#to_hash is missing on GrayLogger::Message"
  end

  def test_converting_a_message_to_a_hash_ensures_that_additional_fields_are_prefixed_with_an_underscore
    message = GrayLogger::Message.new(:my_field => 'my value', :short_message => 'the short message')
    message_hash = message.to_hash
    assert message_hash.keys.include?(:short_message), "the hash doesn't include the short_message"
    assert message_hash.keys.include?(:_my_field), "the hash doesn't include the _my_field"
    assert !message_hash.keys.include?(:my_field), "the hash has a my_field key. This means that it isn't normalized"
  end

  def test_converting_a_message_to_a_hash_sets_the_short_message_if_the_short_message_isn_t_set
    message = GrayLogger::Message.new
    assert message.message_hash[:short_message].nil?, "the short message isn't nil by default?! WTF?"
    message_hash = message.to_hash
    assert !message_hash[:short_message].nil?, "the short message is not set to the default?!"
  end

end