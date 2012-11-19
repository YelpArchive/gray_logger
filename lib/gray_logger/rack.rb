module Rack
  module GrayLogger

    class Middleware
      include ::GrayLogger::Support

      attr_accessor :gray_logger

      def initialize(app)
        @app = app
        ::GrayLogger.proxy.gray_logger = ::GrayLogger::Logger.new(::GrayLogger.configuration.dup)
      end

      def call(env)
        env["rack.gray_logger.proxy"] = ::GrayLogger.proxy
        gray_logger = ::GrayLogger.proxy.gray_logger
        begin
          status, headers, body = @app.call(env)
        rescue => e
          gray_logger.log_exception(e) if gray_logger.automatic_logging?
          raise
        ensure
          req = Rack::Request.new(env)
          if ::GrayLogger.configuration.automatic_logging?
            gray_logger.log_exception(env['rack.exception'])
            gray_logger.after_request_log.status_code = status.to_i
            gray_logger.after_request_log.short_message = "Request: #{req.path} (#{status.to_i})" if gray_logger.after_request_log[:short_message].nil?
            gray_logger.flush
          else
            gray_logger.reset!
          end
          [status, headers, body]
        end

      end

    end

  end
end
