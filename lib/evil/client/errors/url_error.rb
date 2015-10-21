module Evil::Client::Errors

  # Исключение вызывается когда сформированный адрес
  # не может быть преобразован в url удаленного API
  #
  # @author nepalez <nepalez@evilmartians.com>
  #
  class URLError < RuntimeError
    # @!attribute [r] address
    #
    # @return [String] неверный адрес
    #
    attr_reader :address

    # Инициализирует исключение для неверного адреса
    #
    # @param [#to_s] address
    #
    def initialize(address)
      super "The address '#{address}' cannot be resolved to url"
      @address = address.to_s
    end
  end # class URLError

end # module Evil::Client::Errors
