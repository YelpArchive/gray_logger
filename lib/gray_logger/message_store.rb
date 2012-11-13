module GrayLogger

  class MessageStore
    attr_reader :store

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
      if method_name.to_s.end_with?("=")

        # def method_name=(value)
        #   @store[:method_name] = value
        # end
        instance_eval <<-EOMEVAL
          def #{method_name}(value)
            @store[:#{method_name.to_s.chop}] = value
          end
        EOMEVAL

        send(method_name, args)
      end
    end

  end

end
