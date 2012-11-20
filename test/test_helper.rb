require 'minitest-colorize'
require 'mocha/setup'
require 'gray_logger'

class MiniTest::Unit::TestCase

  private
  def build_logger(with_stub=true, logger_configuration={})
    configuration = GrayLogger::Configuration.new(logger_configuration)
    configuration.stubs(:valid?).returns(true) if with_stub
    GrayLogger::Logger.new(configuration)
  end

  def logger_configuration_attributes
    {
      :host => '127.0.0.1',
      :port => '11211'
    }
  end

end

GELF::RubyUdpSender.stubs(:send_datagrams).returns([])
