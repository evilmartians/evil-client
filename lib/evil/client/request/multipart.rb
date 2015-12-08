class Evil::Client::Request
  # Converts a request's body to multipart format with nested keys
  #
  class Multipart < Base
    # Returns multipart body
    #
    # @return [String]
    #
    def build
      [parts.map { |part| [boundary, part] }, "#{boundary}--", "", ""]
        .flatten
        .join("\r\n")
    end

    private

    attr_reader :body

    def boundary
      @boundary ||= "--#{SecureRandom.hex}"
    end

    def parts
      request.flat_body.map do |key, value, file|
        converter = file ? FilePart : ValuePart
        converter.call(key, value)
      end
    end

    # Converts key and value to body part
    #
    # @api private
    #
    class ValuePart
      # Converts the array of [key, value] to the part of body
      #
      # @param [#to_s] key
      # @param [#to_s] value
      #
      # @return [String]
      #
      def self.call(key, value)
        new(key, value).call
      end

      # Initializes the part
      #
      # @param [#to_s] key
      # @param [#to_s] value
      #
      def initialize(key, value)
        @key = key
        @value = value
      end

      # Returns the part of the multipart body
      #
      # @return [String]
      #
      def call
        [headers, "", data].flatten.join("\r\n")
      end

      private

      attr_reader :key, :value

      def headers
        ["Content-Disposition: form-data; name=\"#{key}\""]
      end

      def data
        value
      end
    end

    # Converts key and file to body part
    #
    class FilePart < ValuePart
      private

      def headers
        [content_disposition, content_transfer_encoding, content_type].compact
      end

      def data
        value.read
      end

      def content_disposition
        "Content-Disposition: form-data; name=\"#{key}\"; filename=\"#{name}\""
      end

      def content_transfer_encoding
        "Content-Transfer-Encoding: binary"
      end

      def path
        value.path
      end

      def content_type
        type = MIME::Types.type_for(path).first
        "Content-Type: #{type}" if type
      end

      def name
        Pathname.new(path).basename
      end
    end
  end
end
