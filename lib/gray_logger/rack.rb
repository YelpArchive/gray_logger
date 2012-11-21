module Rack
  module GrayLogger

    class Middleware
      include ::GrayLogger::Support

      attr_accessor :gray_logger

      def initialize(app)
        @app = app
      end

      def call(env)
        gray_logger = ::GrayLogger.proxy.gray_logger
        begin
          gray_logger.reset!
          status, headers, body = @app.call(env)
        rescue Exception => e
          gray_logger.log_exception(e) if gray_logger.automatic_logging?
          raise e
        ensure
          req = Rack::Request.new(env)
          if ::GrayLogger.configuration.automatic_logging?
            gray_logger.log_exception(env['rack.exception']) if env['rack.exception']
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
