module GrayLogger
  module HelperMethods
    def gray_logger
      if Rails.version.to_i >= 3
        env["rack.gray_logger.message_store"]
      else
        request.env["rack.gray_logger.message_store"]
      end
    end
    protected :gray_logger
  end
end
