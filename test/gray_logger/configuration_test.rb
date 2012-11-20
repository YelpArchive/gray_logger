require 'test_helper'
class ConfigurationTest < MiniTest::Unit::TestCase

  def test_initializing_a_new_configuration_instance_configures_itself
    configuration = GrayLogger::Configuration.new(logger_configuration_attributes)
    assert_equal "127.0.0.1", configuration.host, "host is not set."
    assert_equal "11211", configuration.port, "port is not set."
    assert_equal "WAN", configuration.size, "default size is not set."
    assert_equal "facility-not-defined", configuration.options[:facility], "default facility is not set."
  end

  def test_configuration_validating_all_necessary_fields
    %w( host port size ).permutation do |set|
      configuration = GrayLogger::Configuration.new({
        set[0].to_sym => nil,
        set[1].to_sym => "a value",
        set[2].to_sym => "a value"
      })
      assert !configuration.valid?, "#{set[0]} is set to nil and the configuration is valid: FAIL!"
    end
  end

  def test_automatic_logging
    configuration = GrayLogger::Configuration.new(:automatic_logging => false)
    assert !configuration.automatic_logging?
  end

end
