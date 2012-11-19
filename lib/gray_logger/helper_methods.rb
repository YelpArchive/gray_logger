module GrayLogger
  module HelperMethods

    protected
    def gray_logger_proxy
      ::GrayLogger.proxy
    end

    def gray_logger
      ::GrayLogger.proxy.gray_logger
    end

  end
end
