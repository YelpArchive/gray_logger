require 'test_helper'
class MessageTest < Test::Unit::TestCase

  # def initialize(message_hash={})
  #   @message_hash = message_hash
  #   @message = {}
  # end

  def test_ensures_that_short_message_field_is_set
    message = GrayLogger::Message.new({})
    assert !message.to_hash["short_message"].nil?, "short message isn't set: #{message.to_hash.inspect}"
  end


end
