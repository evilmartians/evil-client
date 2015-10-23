module Evil::Client::Errors
  # Исключение вызывается когда сформированный адрес
  # не может быть преобразован в URI одного из зарегистрированных API
  #
  class PathError < RuntimeError
    # @!attribute [r] path
    #
    # @return [String] не найденный адрес
    #
    attr_reader :path

    # Инициализирует исключение для ненайденного адрес
    #
    # @param [#to_s] path Ненайденный адрес
    # @param [Array<Symbol>] api_names Список API по которым велся поиск
    #
    def initialize(path, api_names = [])
      super "#{header api_names} resolve '#{path}' to URI"
      @path = path.to_s
    end

    private

    def header(api_names)
      return "No API can" if api_names.empty?

      names = api_names.map(&:inspect).join(", ")
      "API#{"s:" unless api_names.one?} #{names} cannot"
    end
  end
end
