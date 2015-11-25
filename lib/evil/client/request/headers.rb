class Evil::Client
  class Request
    # Utility to build the final headers of the prepared request
    #
    class Headers < SimpleDelegator
      # Instantiates and calls the utility to return headers
      #
      # @param [Evil::Client::Request] request
      #
      # @return (see #call)
      #
      def self.call(request)
        new(request).call
      end

      # Returns the resulting headers
      #
      # @return [Hash]
      #
      def call
        hash = common_headers
        hash.update(default_headers)
        hash.update(request_id_headers) if request_id
        hash.update(headers) # adds custom headers
      end

      private

      def request_id
        @request_id ||= RequestID.value
      end

      def common_headers
        { "Accept-Charset" => "utf-8" }
      end

      def request_id_headers
        { "X-Request-Id" => request_id }
      end

      def default_headers
        return multipart_headers if multipart?
        return json_headers if json?
        plain_headers
      end

      def json_headers
        {
          "Accept"       => "application/json",
          "Content-Type" => "application/json; charset=utf-8"
        }
      end

      def multipart_headers
        {
          "Accept"              => "plain/text; application/json",
          "Content-Disposition" => "form-data",
          "Content-Type"        => "multipart/form-data"
        }
      end

      def plain_headers
        {
          "Accept"       => "text/plain",
          "Content-Type" => "text/plain; charset=utf-8"
        }
      end
    end
  end
end
