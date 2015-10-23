module Evil::Client::Errors
  # Исключение вызывается когда адрес не поддерживается API
  #
  class PathError < RuntimeError
    # Инициализирует исключение для адреса, который не поддерживается API
    #
    # @param [#to_s] path Ненайденный адрес
    #
    def initialize(path)
      super "Path '#{path}' cannot be resolved to URI"
    end
  end
end
