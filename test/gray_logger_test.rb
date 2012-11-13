require 'test_helper'
class GrayLoggerTest < Test::Unit::TestCase

  def test_configured_shows_the_configuration_status
    logger = GrayLogger::Logger.new
    assert !logger.configured?, "logger is configured."
  end

end
