module GrayLogger

  class Logger < GELF::Logger
    include ::GrayLogger::Support
    attr_reader :buckets, :automatic_logging

    def initialize(configuration={})
      automatic_logging = configuration.delete(:automatic_logging)
      @automatic_logging = automatic_logging.nil? ? true : automatic_logging

      defaults = {
        :size => "WAN",
        :facility => "facility-not-defined"
      }

      config = symbolize_keys(configuration)
      config = defaults.merge(config)

      super(config.delete(:host), config.delete(:port), config.delete(:size), config)

      @buckets = {}
    end

    def automatic_logging?
      !!@automatic_logging
    end

    def reset!
      @buckets = {}
      self
    end

    # logger.after_request_log << {:my_field => 'field content'}
    # logger.after_request_log.my_field = 'field content'
    def after_request_log
      bucket(:_request)
    end

    # logger.bucket(:my_bucket) << {:my_field => 'field content'}
    # logger.bucket(:my_bucket).my_field = 'field content'
    def bucket(name)
      @buckets[name.to_sym] ||= GrayLogger::Bucket.new
    end

    # flush all buckets
    def flush
      @buckets.keys.each do |bucket_name|
        flush_bucket(bucket_name)
      end
      reset!
    end

    # flush a specific bucket
    def flush_bucket(name)
      return false if get_bucket(name).nil?
      message = get_bucket(name).to_message(name)
      self.notify!(message)
      @buckets.delete(name.to_sym)
    end

    def log_exception(exception)
      if exception
        after_request_log.short_message = "Error: #{exception.inspect}"
        after_request_log.exception_backtrace = exception.backtrace.join("\n")
      end
    end

    private
    def get_bucket(name)
      @buckets[name.to_sym]
    end

  end

end