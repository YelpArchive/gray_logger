require 'test_helper'
class MessageStoreTest < Test::Unit::TestCase

  def setup
    @message_store = GrayLogger::MessageStore.new
  end

  def test_add_adds_new_fields_to_the_store
    @message_store.add({:my_test_field => 'my test field'})
    assert_equal 'my test field', @message_store.store[:my_test_field], "the message_store haven't stored the added field: #{@message_store.store.inspect}"
  end

  def test_calling_a_writer_on_message_store_also_sets_a_field
    assert_nothing_raised { @message_store.my_custom_message = 'my custom message' }
    assert_equal 'my custom message', @message_store.store[:my_custom_message], "the message_store haven't stored the added field: #{@message_store.store.inspect}"
  end

  def test_to_message_creates_a_new_message_from_the_store
    @message_store.my_custom_message = 'my custom message'
    message = @message_store.to_message
    assert message.is_a?(GrayLogger::Message), "this didn't return a GrayLogger::Message: #{message.class}"
  end

end
