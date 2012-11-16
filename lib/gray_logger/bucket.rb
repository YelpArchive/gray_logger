module GrayLogger

  class Bucket < Hash
    alias_method :<<, :merge!

    def to_message(name=nil)
      self[:gray_logger_bucket] = name if name
      GrayLogger::Message.new(self)
    end

    def append_to(field_name, value)
      self[field_name.to_sym] ||= ""
      self[field_name.to_sym] << "#{value}\n"
    end

    protected
    def method_missing(method_name, args, &block)
      if method_name.to_s.end_with?("=")

        # def method_name=(value)
        #   self[:method_name] = value
        # end
        instance_eval <<-EOMEVAL
          def #{method_name}(value)
            self[:#{method_name.to_s.chop}] = value
          end
        EOMEVAL

        send(method_name, args)
      end
    end

  end

end
