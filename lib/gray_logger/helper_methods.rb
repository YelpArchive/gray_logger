module GrayLogger
  module HelperMethods
    
    protected
    def gray_logger_proxy
      if Rails.version >= 3
        env["rack.gray_logger.proxy"]
      else
        request.env["rack.gray_logger.proxy"]
      end
    end

    def gray_logger
      gray_logger_proxy.gray_logger
    end

  end
end
