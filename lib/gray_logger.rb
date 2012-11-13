require 'singleton'
require 'gelf'

require 'gray_logger/message'
require 'gray_logger/message_store'
require 'gray_logger/middleware'
require 'gray_logger/helper_methods'


if defined?(Rails) && Rails.version.to_i >= 3
  require 'gray_logger/railtie'
end
