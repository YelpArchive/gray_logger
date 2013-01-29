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
        if gray_logger.nil?
          @app.call(env)
        else
          begin
            gray_logger.reset!
            status, headers, body = @app.call(env)
          rescue Exception => e

            # Ensure the original exception can be re-raised
            begin
              gray_logger.log_exception(e) if gray_logger.automatic_logging?
            rescue
              $stderr.puts "gray_logger threw an error and shouldn't"
            end

            raise e
          ensure
            begin
              req = Rack::Request.new(env)
              if ::GrayLogger.configuration.automatic_logging?
                gray_logger.log_exception(env['rack.exception']) if env['rack.exception']
                gray_logger.after_request_log.status_code = status.to_i
                gray_logger.after_request_log.short_message = "Request: #{req.path} (#{status.to_i})" if gray_logger.after_request_log[:short_message].nil?
                gray_logger.flush
              else
                gray_logger.reset!
              end
            rescue Exception => e
              $stderr.puts "gray_logger threw an error and shouldn't"
            ensure
              [status, headers, body]
            end
          end
        end
      end

    end

  end
end
