class Evil::Client
  class Request
    # Utility to build the final body of the prepared request
    #
    class Body < SimpleDelegator
      # Instantiates and calls the utility to return a body
      #
      # @param [Evil::Client::Request] request
      #
      # @return (see #call)
      #
      def self.call(request)
        new(request).call
      end

      # Returns the resulting body
      #
      # @return [nil, String, Hash]
      #
      def call
        return if type == "get"
        prepare_for_files!(body) if defined? ::Rails
        return body unless json?

        JSON.generate(body)
      end

      private

      def prepare_for_files!(values)
        actiondispatch_files = values.find_all do |_, value|
          ActionDispatch::Http::UploadedFile =~ value
        end

        actiondispatch_files.each do |(key, file)|
          values.update(key => UploadFile.new(file))
        end
      end
    end
  end
end
