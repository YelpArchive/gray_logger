require 'gelf'

require 'gray_logger/support'
require 'gray_logger/proxy'
require 'gray_logger/configuration'
require 'gray_logger/bucket'
require 'gray_logger/message'
require 'gray_logger/logger'
require 'gray_logger/rack'
require 'gray_logger/helper_methods'

if defined?(Rails)
  require 'gray_logger/rails_modules'
  require 'gray_logger/railtie' if defined?(Rails::Railtie)
end

module GrayLogger

  class << self
    attr_accessor :configuration
  end

  # GrayLogger.configure({:host => '127.0.0.1'}) do |config|
  #   config.port = "11200"
  # end
  def self.configure(config)
    self.configuration = ::GrayLogger::Configuration.new(config)
    yield(configuration) if block_given?
  end

end

