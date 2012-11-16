module GrayLogger
  module RailsModules
    module ActionControllerCatcher

      # Sets up an alias chain to catch exceptions when Rails does
      def self.included(base) #:nodoc:
        base.send(:alias_method, :rescue_action_without_gray_logger, :rescue_action)
        base.send(:alias_method, :rescue_action, :rescue_action_with_gray_logger)
      end

      private

      # Overrides the rescue_action method in ActionController::Base, but does not inhibit
      # any custom processing that is defined with Rails 2's exception helpers.
      def rescue_action_with_gray_logger(exception)
        gray_logger.log_exception(exception)
        rescue_action_without_gray_logger(exception)
      end
    end
  end  
end

ActionController::Base.send(:include, GrayLogger::RailsModules::ActionControllerCatcher)
