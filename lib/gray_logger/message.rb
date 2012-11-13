module GrayLogger

  class Message
    include GrayLogger::Support

    RESERVED_KEYS = %( short_message full_message version host timestamp level facility line file )

    attr_reader :message_hash, :message

    def initialize(message_hash={})
      @message_hash = message_hash
      @message = {}
    end

    def to_hash
      prepare_hash
      ensure_necessary_keys_are_present
      symbolize_keys(@message)
    end

    private

    def prepare_hash
      @message = @message_hash.inject({}) do |hash, key_value|
        key = normalize_key(key_value[0])
        hash[key] = key_value[1]
        hash
      end
    end

    def ensure_necessary_keys_are_present
      if @message["short_message"].nil? && @message[:short_message].nil?
        @message["short_message"] = "short_message missing!"
      end
    end

    def normalize_key(key)
      if key.to_s.start_with?('_')
        key
      else
        RESERVED_KEYS.include?(key.to_s) ? key : "_#{key}"
      end
    end

  end

end
