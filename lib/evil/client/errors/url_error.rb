module Evil::Client::Errors
  # Exception for the case API +base_url+ isn't valid
  class URLError < RuntimeError
    # Initializes exception for wrong URL
    #
    # @param [#to_s] url
    #
    def initialize(url)
      super "Invalid URL '#{url}'. Both protocol and host must be defined."
    end
  end
end
