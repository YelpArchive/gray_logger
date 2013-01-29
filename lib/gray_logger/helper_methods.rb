module GrayLogger
  module HelperMethods

    protected

    def with_gray_logger
      yield if defined?(gray_logger) && !gray_logger.nil?
    end

    def gray_logger_proxy
      ::GrayLogger.proxy
    end

    def gray_logger
      ::GrayLogger.proxy.gray_logger
    end

  end
end
