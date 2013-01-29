module GrayLogger

  class Railtie < Rails::Railtie

    begin
      initializer "gray_logger.configure_rails_initialization" do |app|
        configuration = YAML.load(File.read(Rails.root.join('config/gray_logger.yml')))[Rails.env]

        if configuration.try(:key?, "enabled")
          overrides = {}
          overrides[:host] = ENV['GRAY_LOGGER_HOST']     if ENV['GRAY_LOGGER_HOST']
          overrides[:port] = ENV['GRAY_LOGGER_PORT']     if ENV['GRAY_LOGGER_PORT']
          overrides[:size] = ENV['GRAY_LOGGER_MAX_SIZE'] if ENV['GRAY_LOGGER_MAX_SIZE']

          ::GrayLogger.configure(configuration.merge(overrides))
          ::GrayLogger.proxy.initialize_gray_logger!

          app.middleware.insert_after "ActionDispatch::ShowExceptions", "Rack::GrayLogger::Middleware"
        end
      end
    rescue => e
      $stderr.puts("GrayLogger not configured. Please add config/gray_logger.yml")
    ensure
      ActionController::Base.send(:include, ::GrayLogger::HelperMethods)
    end

  end

end
