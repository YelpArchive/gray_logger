module GrayLogger

  class Middleware
    include GrayLogger::Support

    attr_accessor :gray_logger

    def initialize(app, options={})
      @app = app
      configuration = symbolize_keys(options.delete(:configuration))
      self.gray_logger = if configuration && configuration[:host] && configuration[:port]
        size = ENV['GRAYLOGGER_SIZE'] || configuration.delete(:size) || "WAN"
        GELF::Logger.new(configuration.delete(:host), configuration.delete(:port), size, configuration)
      else
        options.delete(:logger)
      end
    end

    def call(env)

      begin
        message_store = env["rack.gray_logger.message_store"] = GrayLogger::MessageStore.new(:level => GELF::INFO)
        status, headers, body = @app.call(env)
      rescue => e
        message_store.short_message = "Error: #{e.inspect}"
        message_store.exception_backtrace = e.backtrace.join("\n")
        raise
      ensure
        error = env['rack.exception']
        if error
          message_store.short_message = "Error: #{error.inspect}"
          message_store.exception_backtrace = error.backtrace.join("\n")
        end
        message_store.status_code = status.to_i
        gray_logger.notify!(message_store.to_message) unless gray_logger.nil?
        [status, headers, body]
      end

    end

  end

end
