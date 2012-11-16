module GrayLogger
  class Configuration
    include ::GrayLogger::Support

    attr_accessor :host, :port, :size, :automatic_logging, :options
    def initialize(configuration_hash)
      defaults = {
        :size => "WAN",
        :facility => "facility-not-defined"
      }

      config = symbolize_keys(configuration_hash)
      config = defaults.merge(config)

      [:host, :port, :size, :automatic_logging].each do |method|
        send("#{method}=", config.delete(method))
      end
      self.options = config
    end

  end
end