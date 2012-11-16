module GrayLogger
  module HelperMethods
    def gray_logger
      Rack::GrayLogger.proxy.gray_logger
    end
    protected :gray_logger
  end
end
