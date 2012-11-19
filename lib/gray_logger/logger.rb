module GrayLogger

  class Logger < GELF::Logger
    include ::GrayLogger::Support

    @last_chunk_id = 0

    attr_reader :buckets, :configuration

    def initialize(configuration)
      super(configuration.host, configuration.port, configuration.size, configuration.options)
      @configuration = configuration

      @buckets = {}
    end

    def reset!
      @buckets = {}
      self
    end

    def automatic_logging?
      configuration.automatic_logging?
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