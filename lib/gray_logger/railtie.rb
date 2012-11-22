module GrayLogger

  class Railtie < Rails::Railtie

    begin
      initializer "gray_logger.configure_rails_initialization" do |app|
        configuration = YAML.load(File.read(Rails.root.join('config/gray_logger.yml')))[Rails.env]
        ::GrayLogger.configure(configuration)
        ::GrayLogger.proxy.initialize_gray_logger!

        ActionController::Base.send(:include, ::GrayLogger::HelperMethods)

        app.middleware.insert_after "ActionDispatch::ShowExceptions", "Rack::GrayLogger::Middleware"
      end
    rescue => e
      $stderr.puts("GrayLogger not configured. Please add config/gray_logger.yml")
    end

  end

end
