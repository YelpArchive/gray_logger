module GrayLogger
  class Proxy
    attr_accessor :proxied_logger

    def initialize(attributes={})
      self.proxied_logger = attributes[:proxied_logger]
      @gray_logger = attributes[:gray_logger]
    end

    def gray_logger
      @gray_logger
    end

    def gray_logger?
      !!@gray_logger
    end

    def initialize_gray_logger!
      @gray_logger = ::GrayLogger::Logger.new(::GrayLogger.configuration)
    end

    # def debug(*args)
    #   if proxied_logger.nil?
    #     gray_logger.send(:debug, *args)
    #   else
    #     if !gray_logger.nil? && gray_logger.debug?
    #       gray_logger.after_request_log.append_to(:log_file, "[debug] #{args[0]}")
    #     end
    #     proxied_logger.send(:debug, *args)
    #   end
    # end
    GELF::Levels.constants.each do |const|
      class_eval <<-EOT, __FILE__, __LINE__ + 1
        def #{const.downcase}(*args)
          if proxied_logger.nil?
            gray_logger.send(:#{const.downcase}, *args) if gray_logger?
          else
            if gray_logger? && gray_logger.#{const.downcase}?
              gray_logger.after_request_log.append_to(:log_file, "[#{const.downcase}] \#{args[0]}")
            end
            proxied_logger.send(:#{const.downcase}, *args)
          end
        end
      EOT
    end

    private
    # delegate every method the proxy doesn't know to gray_logger and proxied_logger. let them handle this.
    def method_missing(method_name, *args, &block)
      unless proxied_logger.nil?
        begin
          proxied_logger.send(method_name, *args, &block)
        rescue => e
          proxied_logger.error(e.backtrace.join("\n"))
        end
      end
    end
  end

  def self.proxy= proxy
    @proxy = proxy
  end

  def self.proxy
    @proxy ||= ::GrayLogger::Proxy.new
  end
end
