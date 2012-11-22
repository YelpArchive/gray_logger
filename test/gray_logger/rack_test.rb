require 'test_helper'

module Rack
  class Request
    def initialize(*args)
    end
    def path
      "/users"
    end
  end
end


class RackTest < MiniTest::Unit::TestCase
  def setup
    ::GrayLogger.configuration = ::GrayLogger::Configuration.new(logger_configuration_attributes)
    ::GrayLogger.proxy.initialize_gray_logger!
  end

  def test_calling_the_middleware_clears_the_gray_logger_buckets
    ::GrayLogger.proxy.gray_logger.expects(:reset!).twice # we are calling it before the request and after the request.
    middleware.call(middleware_env)
  end

  def test_when_an_exception_happens_in_the_middleware_the_exception_is_logged_to_graylog
    exception = Exception.new("an exception_message")
    ::GrayLogger.proxy.gray_logger.stubs(:reset!).raises(exception)
    ::GrayLogger.proxy.gray_logger.stubs(:automatic_logging?).returns(true)
    ::GrayLogger.proxy.gray_logger.expects(:log_exception).with(exception)
    assert_raises Exception do
      middleware.call(middleware_env)
    end
  end

  def test_logs_the_exception_when_the_rack_exception_field_is_set_in_the_env
    exception = Exception.new("an exception_message")
    middleware_env["rack.exception"] = exception
    ::GrayLogger.proxy.gray_logger.stubs(:automatic_logging?).returns(true)
    ::GrayLogger.proxy.gray_logger.expects(:log_exception).with(exception)
    middleware.call(middleware_env)
  end

  def test_finishing_the_request_sets_the_short_message_and_the_status_code
    ::GrayLogger.configuration.stubs(:automatic_logging?).returns(true)
    ::GrayLogger.proxy.gray_logger.after_request_log.short_message = nil
    ::GrayLogger.proxy.gray_logger.stubs(:flush)

    middleware.call(middleware_env)

    assert_equal 200, ::GrayLogger.proxy.gray_logger.after_request_log[:status_code]
    assert_equal "Request: /users (200)", ::GrayLogger.proxy.gray_logger.after_request_log[:short_message]
  end

  def test_finishing_the_request_flushes_all_buckets
    ::GrayLogger.configuration.stubs(:automatic_logging?).returns(true)
    ::GrayLogger.proxy.gray_logger.expects(:flush)

    middleware.call(middleware_env)
  end

  def test_finishing_the_request_flushes_all_buckets
    ::GrayLogger.configuration.stubs(:automatic_logging?).returns(false)
    ::GrayLogger.proxy.gray_logger.expects(:flush).never
    ::GrayLogger.proxy.gray_logger.expects(:reset!).twice # first one before the app.call. the second one is the interesting thing here.

    middleware.call(middleware_env)
  end

  def test_the_middleware_shouldn_t_return_an_empty_body_when_gray_logger_isn_t_defined
    ::GrayLogger.proxy.stubs(:gray_logger).returns(nil)
    result = middleware.call(middleware_env)
    assert_equal ["200 ok", "headers", "body"], result
  end

  private
  def middleware
    return @middleware if @middleware
    app = mock("app")
    app.stubs(:call).returns(["200 ok", "headers", "body"])
    @middleware = ::Rack::GrayLogger::Middleware.new(app)
  end
  def middleware_env
    @middleware_env ||= {}
  end

end
