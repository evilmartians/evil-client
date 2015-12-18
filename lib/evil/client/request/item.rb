class Evil::Client::Request
  # Describes a single item of nested hash
  #
  # @api private
  #
  class Item
    include Equalizer.new(:key, :value)

    # Initializes a value from raw unescaped value and array of its keys
    #
    # @param [Object] raw_value
    # @param [Array<#to_s>] keys
    #
    def initialize(raw_value, keys)
      @raw_value = raw_value
      @keys      = keys.map { |key| CGI.escape key.to_s }
    end

    # The nested escaped key for the item
    #
    # @return [String]
    #
    def key
      @key ||= @keys.inject { |prefix, key| "#{prefix}[#{key}]" }
    end

    # The value stringified and escaped when necessary
    #
    # @return [String, File, nil]
    #
    def value
      @value ||=
        if @raw_value.nil? || file?
          @raw_value
        else
          CGI.escape(@raw_value.to_s)
        end
    end

    # The predicate to check whether [#value] is a file
    #
    # @return [Boolean]
    #
    def file?
      if @file.nil?
        @file = @raw_value.respond_to?(:read) && @raw_value.respond_to?(:path)
      end
      @file
    end

    # Converts item to single string
    #
    # @return [String]
    #
    def to_s
      [key, value].compact.join("=")
    end

    # Converts item to the part of multipart body
    #
    # @return [String]
    #
    def to_part
      [headers, "", data].flatten.join("\r\n")
    end

    private

    def headers
      if file?
        [content_disposition, content_transfer_encoding, content_type].compact
      else
        ["Content-Disposition: form-data; name=\"#{key}\""]
      end
    end

    def data
      file? ? value.read : value
    end

    def path
      value.path
    end

    def name
      CGI.escape File.basename(path)
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
  end
end
