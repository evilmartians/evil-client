module Evil::Client::Errors
  # Исключение вызывается когда base_url некорректен
  #
  class URLError < RuntimeError
    # @!attribute [r] url
    #
    # @return [String] некорректный URL
    #
    attr_reader :url

    # Инициализирует исключение для ошибочного URL
    #
    # @param [#to_s] url
    #
    def initialize(url)
      super "Invalid URL '#{url}'. Both protocol and host must be defined."
      @url = url.to_s
    end
  end
end
