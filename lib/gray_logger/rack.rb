module Rack
  module GrayLogger
    class Middleware
      include ::GrayLogger::Support

      attr_accessor :gray_logger

      def initialize(app, options={})
        @app = app

        configuration = symbolize_keys(options.delete(:configuration))
        self.gray_logger = ::GrayLogger::Logger.new(configuration)

        ::Rack::GrayLogger.proxy.gray_logger = gray_logger if ::Rack::GrayLogger.proxy
      end

      def call(env)

        begin
          status, headers, body = @app.call(env)
        rescue => e
          gray_logger.log_exception(e) if gray_logger.automatic_logging?
          raise
        ensure
          req = Rack::Request.new(env)
          if gray_logger.automatic_logging?
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

    class Proxy
      attr_accessor :proxied_logger, :gray_logger

      def initialize(attributes={})
        self.proxied_logger = attributes[:proxied_logger]
        self.gray_logger = attributes[:gray_logger]
      end

      # def debug(*args)
      #   if proxied_logger.nil?
      #     super(*args)
      #   else
      #     after_request_log.append_to(:log_file, "[debug] #{args[0]}") unless gray_logger.nil?
      #     proxied_logger.send(:debug, *args)
      #   end
      # end
      GELF::Levels.constants.each do |const|
        class_eval <<-EOT, __FILE__, __LINE__ + 1
          def #{const.downcase}(*args)
            if proxied_logger.nil?
              gray_logger.send(:#{const.downcase}, *args)
            else
              gray_logger.after_request_log.append_to(:log_file, "[#{const.downcase}] \#{args[0]}") unless gray_logger.nil?
              proxied_logger.send(:#{const.downcase}, *args)
            end
          end
        EOT
      end
      private
      def method_missing(method_name, *args, &block)
        unless gray_logger.nil?
          begin
            gray_logger.send(method_name, *args, &block)
          rescue => e
            gray_logger.handle_exception(e)
          end
        end
        unless proxied_logger.nil?
          begin
            proxied_logger.send(method_name, *args, &block)
          rescue => e
            proxied_logger.error(e.backtrace.join("\n"))
          end
        end
      end

    end

    # config.logger = Rack::GrayLogger.after_request_proxy(SysLogger.new)
    def self.after_request_proxy(proxied_logger)
      self.proxy = Rack::GrayLogger::Proxy.new(:proxied_logger => proxied_logger)
      proxy
    end

    def self.proxy= proxy
      @proxy = proxy
    end

    def self.proxy
      @proxy
    end

  end
end
