require 'singleton'
require 'gelf'

require 'gray_logger/support'
require 'gray_logger/message'
require 'gray_logger/message_store'
require 'gray_logger/middleware'
require 'gray_logger/helper_methods'


if defined?(Rails)
  require 'gray_logger/rails_modules'
  require 'gray_logger/railtie' if defined?(Rails::Railtie)
end
