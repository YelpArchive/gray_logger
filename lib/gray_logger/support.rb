module GrayLogger

  module Support

    def self.included(base)
      base.extend(SupportMethods)
      base.send(:include, SupportMethods)
    end

    module SupportMethods

      private
      def symbolize_keys(hash)
        return {} if hash.nil?
        hash.inject({}) do |hash, key_value|
          hash[key_value[0].to_sym] = key_value[1]
          hash
        end
      end

    end

  end

end
