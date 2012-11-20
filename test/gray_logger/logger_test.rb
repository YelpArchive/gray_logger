require 'test_helper'
class LoggerTest < MiniTest::Unit::TestCase

  def test_configured_in_correct_way_we_get_a_working_logger_that_logs_to_graylog
    GrayLogger::Logger.any_instance.stubs(:super).returns({})
    logger = build_logger(true)
    assert logger.enabled, "logger is disabled. :("
  end

  def test_disables_the_gelf_notifier_if_not_configured_correctly
    logger = build_logger(false)
    assert !logger.enabled, "logger is enabled. :("
  end

  def test_resetting_resets_all_buckets
    logger = build_logger
    logger.bucket(:my_bucket_name).my_field = "test-value"
    assert !logger.bucket(:my_bucket_name)[:my_field].nil?, "the bucket is nil :("
    logger.reset!
    assert logger.bucket(:my_bucket_name)[:my_field].nil?, "the bucket is not resetted :("
  end

  def test_automatic_logging_checks_if_automatic_logging_is_enabled
    logger = build_logger(true, {:automatic_logging => false})
    assert !logger.automatic_logging?, "automatic_logging was set to false but the method returns true. :("
    logger.configuration.automatic_logging = true
    assert logger.automatic_logging?, "automatic_logging was set to true but the method returns false. :("
  end

  def test_after_request_log_is_a_handy_method_for_accessing_the_internal_after_request_log_bucket
    logger = build_logger
    logger.expects(:bucket).with(:_request).returns(GrayLogger::Bucket.new)
    logger.after_request_log
  end

  def test_bucket_gets_a_stored_bucket_or_initializes_a_new_one
    logger = build_logger
    assert !logger.bucket(:my_bucket).nil?, "bucket returns nil and should return a bucket."
    logger.bucket(:my_bucket).my_field = "a tiny value"
    assert_equal "a tiny value", logger.bucket(:my_bucket)[:my_field]
  end

  def test_flush_flushes_all_buckets
    logger = build_logger
    logger.bucket(:my_first_bucket).my_first_field = "a first value"
    logger.bucket(:my_second_bucket).my_first_field = "a second value"
    logger.expects(:flush_bucket).twice
    logger.flush
    assert logger.bucket(:my_first_bucket)[:my_first_field].nil?, "the first field of the first bucket was found. :("
    assert logger.bucket(:my_second_bucket)[:my_second_field].nil?, "the first field of the second bucket was found. :("
  end

  def test_flush_bucket_flushes_a_specific_bucket
    logger = build_logger
    logger.bucket(:my_bucket).a_name = "Michael Knight"
    logger.expects(:notify!)
    logger.flush_bucket(:my_bucket)
    assert logger.bucket(:my_bucket)[:a_name].nil?, "the bucket wasn't emptied after flushing it."
  end

  def test_log_exception_generates_a_meaningful_error_message_to_the_after_request_log_bucket
    logger = build_logger
    assert logger.after_request_log[:short_message].nil?, "the short_message is already set to: #{logger.after_request_log[:short_message]}"
    assert logger.after_request_log[:exception_backtrace].nil?, "the exception_backtrace is already set to: #{logger.after_request_log[:exception_backtrace]}"
    exception = Exception.new("the exception short message")
    exception.set_backtrace(["line 1", "line 2"])
    logger.log_exception(exception)
    assert_equal "Error: #{exception.inspect}", logger.after_request_log[:short_message], "the short message is set to: #{logger.after_request_log[:short_message]} :("
    assert_equal "line 1\nline 2", logger.after_request_log[:exception_backtrace], "the exception backtrace is set to: #{logger.after_request_log[:exception_backtrace]} :("
  end


  private
  def build_logger(with_stub=true, logger_configuration={})
    configuration = GrayLogger::Configuration.new(logger_configuration)
    configuration.stubs(:valid?).returns(true) if with_stub
    GrayLogger::Logger.new(configuration)
  end

end
