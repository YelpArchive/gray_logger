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
        message_store.oder_exception_backtrace = e.backtrace.to_s
        raise e
      ensure
        message_store.status_code = status.to_i
        gray_logger.notify!(message_store.to_message) unless gray_logger.nil?
      end

    end

  end

end
