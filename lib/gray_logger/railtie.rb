module GrayLogger

  class Railtie < Rails::Railtie

    begin
      initializer "gray_logger.configure_rails_initialization" do |app|
        configuration = YAML.load(File.read(Rails.root.join('config/gray_logger.yml')))[Rails.env]
        app.middleware.insert_after "ActionDispatch::ShowExceptions", "Rack::GrayLogger::Middleware", :configuration => configuration
      end
    rescue => e
      $stderr.puts("GrayLogger not configured. Please add config/gray_logger.yml")
    end

    initializer "gray_logger.include_logger" do |app|
      ActionController::Base.send(:include, ::GrayLogger::HelperMethods)
    end

  end

end
