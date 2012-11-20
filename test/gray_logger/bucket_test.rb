require 'test_helper'
class BucketTest < MiniTest::Unit::TestCase

  def test_to_message_converts_a_bucket_into_a_gray_logger_message
    bucket = GrayLogger::Bucket.new
    message = bucket.to_message
    assert message.is_a?(GrayLogger::Message)
  end

  def test_append_to_adds_a_value_to_a_field
    bucket = GrayLogger::Bucket.new
    assert bucket[:my_field_name].nil?
    bucket.append_to(:my_field_name, "my_first_value")
    assert_equal "my_first_value\n", bucket[:my_field_name]
    bucket.append_to(:my_field_name, "my_second_value")
    assert_equal "my_first_value\nmy_second_value\n", bucket[:my_field_name]
  end

  def test_calling_a_setter_on_a_bucket_that_doesn_t_exist
    bucket = GrayLogger::Bucket.new
    assert !bucket.methods.include?("my_field_name="), "my_field_name= already exists on a bucket instance."
    bucket.my_field_name = "my_first_value"
    assert bucket.methods.include?("my_field_name="), "my_field_name= doesn't exist on the bucket instance."
    assert_equal "my_first_value", bucket[:my_field_name]
  end

end
