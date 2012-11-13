module GrayLogger

  class MessageStore

    def initialize(store={})
      @store = store
    end

    # gets a hash with fields
    def add(field_set)
      field_set.each_pair do |field, value|
        @store[field.to_sym] = value
      end
      @store
    end
    alias_method :<<, :add

    def to_message
      GrayLogger::Message.new(@store)
    end

    protected
    def method_missing(method_name, args, &block)
      if method_name.to_s.ends_with?("=")

        # def method_name=(value)
        #   @store[:method_name] = value
        # end
        class_eval <<-EOMEVAL
          def #{method_name}(value)
            @store[:#{method_name.to_s[0..-2]}] = value
          end
        EOMEVAL

        send(method_name, args)
      end
    end

  end

end
