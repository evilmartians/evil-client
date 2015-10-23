module Evil::Client::Errors
  # Исключение вызывается когда base_url некорректен
  #
  class URLError < RuntimeError
    # Инициализирует исключение для ошибочного URL
    #
    # @param [#to_s] url
    #
    def initialize(url)
      super "Invalid URL '#{url}'. Both protocol and host must be defined."
    end
  end
end
