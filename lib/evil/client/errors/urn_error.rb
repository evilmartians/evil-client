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
    # @param [#to_s] urn
    #
    def initialize(urn)
      super "The URN '#{urn}' cannot be resolved to URI"
      @urn = urn.to_s
    end
  end
end
