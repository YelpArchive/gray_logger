module GrayLogger
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

  def self.proxy= proxy
    @proxy = proxy
  end

  def self.proxy
    @proxy ||= ::GrayLogger::Proxy.new
  end
end
