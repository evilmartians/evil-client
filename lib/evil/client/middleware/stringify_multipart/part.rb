class Evil::Client::Middleware::StringifyMultipart
  # Takes a file with its options and builds a part of multipart body
  class Part
    extend Dry::Initializer::Mixin
    option :file
    option :type,     default: proc { MIME::Types["text/plain"].first }
    option :charset,  default: proc { "utf-8" }
    option :name,     default: proc { "AttachedFile" }
    option :filename, default: proc { default_filename }

    def to_s
      [content_disposition, content_type, nil, content].join("\r\n")
    end

    private

    def default_filename
      return Pathname.new(file.path).basename if file.respond_to? :path
      "#{SecureRandom.hex(10)}.#{type.preferred_extension}"
    end

    def content_disposition
      "Content-Disposition: form-data;" \
      " name=\"#{name}\";" \
      " filename=\"#{filename}\""
    end

    def content_type
      "Content-Type: #{type}; charset=#{charset}"
    end

    def content
      file.respond_to?(:read) ? file.read : file
    end
  end
end
