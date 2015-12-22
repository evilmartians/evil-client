class Evil::Client::Request
  # Represents a request query as an array of items following Rails convention
  #
  # @api public
  #
  class Body < Items
    # Returns the resulting body
    #
    # @return [String]
    #
    def final
      return unless any?
      multipart? ? to_multipart : to_line
    end

    private

    def to_line
      map(&:to_s).join("&")
    end

    def to_multipart
      [parts, "#{boundary}--", "", ""].flatten.join("\r\n")
    end

    def boundary
      @boundary ||= "--#{SecureRandom.hex}"
    end

    def parts
      [boundary].product map(&:to_part)
    end
  end
end
