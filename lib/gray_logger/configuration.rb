module GrayLogger
  class Configuration
    include ::GrayLogger::Support

    attr_accessor :host, :port, :size, :automatic_logging, :logger_level, :options
    def initialize(configuration_hash)
      unless configuration_hash.nil?
        configuration = configuration_hash.dup
        defaults = {
          :size => "WAN",
          :facility => "facility-not-defined"
        }

        config = symbolize_keys(configuration)
        config = defaults.merge(config)

        [:host, :port, :size, :automatic_logging, :logger_level].each do |method|
          send("#{method}=", config.delete(method))
        end
        self.options = config
      end
    end

    def valid?
      invalid_host = self.host.nil?
      invalid_port = self.port.nil?
      invalid_size = self.size.nil?
      !(invalid_host || invalid_port || invalid_size)
    end

    def automatic_logging?
      @automatic_logging.nil? ? true : !!@automatic_logging
    end

  end
end