module Evil::Client::Errors
  # Исключение вызывается когда сформированный URN
  # не может быть преобразован в URI одного из зарегистрированных API
  #
  class URNError < RuntimeError
    # @!attribute [r] urn
    #
    # @return [String] не найденный URN
    #
    attr_reader :urn

    # Инициализирует исключение для ненайденного URN
    #
    # @param [#to_s] urn Не найденный URN
    # @param [Array<Symbol>] api_names Список API по которым велся поиск
    #
    def initialize(urn, api_names = [])
      super "#{header api_names} resolve '#{urn}' to URI"
      @urn = urn.to_s
    end

    private

    def header(api_names)
      return "No API can" if api_names.empty?

      names = api_names.map(&:inspect).join(", ")
      "API#{"s:" unless api_names.one?} #{names} cannot"
    end
  end
end
