require "test_helper"
require "logger"

class ProxyTest < MiniTest::Unit::TestCase

  def test_calling_info_on_a_fully_configured_proxy
    proxied_logger = ::Logger.new($stdout)
    gray_logger = build_logger
    proxy = GrayLogger::Proxy.new(:proxied_logger => proxied_logger, :gray_logger => gray_logger)
    proxied_logger.expects(:info).with("test message")
    after_request_log_mock = mock("after_request_log")
    after_request_log_mock.expects(:append_to).with(:log_file, "[info] test message")
    gray_logger.stubs(:after_request_log).returns(after_request_log_mock)
    proxy.info("test message")
  end

  def test_calling_info_on_a_proxy_without_proxied_logger
    gray_logger = build_logger(false, logger_configuration_attributes)
    proxied_logger = ::Logger.new($stdout)
    proxy = GrayLogger::Proxy.new(:gray_logger => gray_logger)
    proxied_logger.expects(:info).never
    proxy.info("test message")
  end

  def test_instatiating_a_new_proxy_sets_the_proxied_logger_and_the_gray_logger
    proxied_logger = ::Logger.new($stdout)
    gray_logger = build_logger
    proxy = GrayLogger::Proxy.new(:proxied_logger => proxied_logger, :gray_logger => gray_logger)
    assert_equal proxied_logger, proxy.proxied_logger, "the proxied_logger isn't set."
    assert_equal gray_logger, proxy.gray_logger, "the gray_logger isn't set."
  end

  def test_a_gray_logger_with_log_level_info_doesn_t_log_stuff_with_log_level_debug
    GrayLogger.configuration = GrayLogger::Configuration.new(logger_configuration_attributes)
    proxied_logger = ::Logger.new($stdout)
    proxy = GrayLogger::Proxy.new(:proxied_logger => proxied_logger)
    proxy.initialize_gray_logger!
    proxy.gray_logger.level = GELF::INFO
    proxy.gray_logger.expects(:debug).never
    proxy.proxied_logger.expects(:debug).with("stuff")
    proxy.debug("stuff")
  end

end
