class Evil::Client::Request
  # Utility to build a final body of a prepared request
  #
  # @api private
  #
  class Body < Base
    # Returns the resulting body
    #
    # @return [String]
    #
    def build
      case
      when request.type == 'get'
        nil
      when items.multipart?
        to_multipart
      else
        items.url_encoded
      end
    end

    private

    def items
      @items ||= Items.new(request.body)
    end

    def to_multipart
      [parts, "#{boundary}--", "", ""].flatten.join("\r\n")
    end

    def boundary
      @boundary ||= "--#{SecureRandom.hex}"
    end

    def parts
      items.map { |item| item.file? ? FilePart.build(item) : Part.build(item) }
    end

    # Builder of simple part of a multipart body
    #
    # @api private
    #
    class Part < SimpleDelegator
      # Builds a body from item
      #
      # @param [Evil::Client::Request::Items::Item] item
      #
      # @return [String]
      #
      def self.build(item)
        new(item).build
      end

      # Builds a body from the current item
      #
      # @return [String]
      #
      def build
        [headers, "", data].flatten.join("\r\n")
      end

      private

      def headers
        ["Content-Disposition: form-data; name=\"#{key}\""]
      end

      def data
        value
      end
    end

    # Builder of file part of a multipart body
    #
    # @api private
    #
    class FilePart < Part
      private

      def headers
        [content_disposition, content_transfer_encoding, content_type].compact
      end

      def data
        value.read
      end

      def path
        value.path
      end

      def content_disposition
        "Content-Disposition: form-data; name=\"#{key}\"; filename=\"#{name}\""
      end

      def content_transfer_encoding
        "Content-Transfer-Encoding: binary"
      end

      def content_type
        type = MIME::Types.type_for(path).first
        "Content-Type: #{type}" if type
      end

      def name
        CGI.escape File.basename(path)
      end
    end
  end
end
