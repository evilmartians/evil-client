module Evil::Client::Formatter
  #
  # Utility module to format source as a part of multipart body
  #
  module Part
    extend self
    require_relative "form"

    # Formats nested hash as a string
    #
    # @param  [IO, #to_s] source
    # @param  [Integer] number
    # @return [String]
    #
    def call(source, number)
      filename = extract_filename(source)
      name     = extract_name(filename, number)
      path     = Pathname.new(filename) if filename
      content  = extract_content(source)
      mime     = extract_mime(path)
      charset  = extract_charset(content)
      headers  = [disposition(name, filename), type(mime, charset), nil]

      [*headers, content].join("\r\n")
    end

    private

    def disposition(name, filename)
      "Content-Disposition: form-data; name=\"#{name}\"".tap do |line|
        line << "; filename=\"#{filename}\"" if filename
      end
    end

    def type(mime, charset)
      "Content-Type: #{mime}; charset=#{charset}"
    end

    def extract_name(filename, number)
      filename || "Part#{number}"
    end

    def extract_content(source)
      case source
      when File, Tempfile then source.read
      when StringIO       then source.string
      when Hash           then Form.call(source)
      else source.to_s
      end
    end

    def extract_filename(source)
      case source
      when File, Tempfile then Pathname.new(source.path).basename.to_s
      end
    end

    def extract_mime(path)
      MIME::Types.type_for(path&.extname.to_s).first || "text/plain"
    end

    def extract_charset(content)
      content.encoding.to_s.downcase
    end
  end
end
