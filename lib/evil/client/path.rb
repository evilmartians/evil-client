class Evil::Client
  # Построитель относительного адреса
  #
  # Любой метод (объекта или класса) без восклицательных знаков интерпретируется
  # как часть имени и возвращает обновленный адрес с добавленной частью.
  #
  # Метод [#call] (с алиасом +[]+) используется для вставки в адрес
  # динамической части (также возвращает обновленный адрес).
  #
  # Метод [#finalize!] без аргументов возвращает итоговую строку адреса
  #
  #     Path.users[1].sms.finalize! # => "users/1/sms"
  #
  # @api private
  #
  class Path
    # Добавляет динамическую часть к адресу и возвращает обновленный адрес
    #
    # @param [#to_s] part
    #
    # @return [Evil::Client::Path]
    #
    def call(part)
      self.class.new(@parts + [part])
    end
    alias_method :[], :call

    # Возвращает сформированную строку адреса
    #
    # @return [String]
    #
    def finalize!
      @parts.join("/")
    end

    protected

    # Изменяет текущий объект путем добавления к нему части адреса
    #
    # @param [#to_s] part
    #
    # @return [Evil::Client::Path]
    #
    def call!(part)
      @parts << part
      self
    end

    private

    REGULAR = /^\w+$/

    def initialize(parts = [])
      @parts = parts
    end

    def method_missing(name, *args)
      (name[REGULAR] && args.empty?) ? call(name) : super
    end

    def respond_to_missing?(name, *)
      !!name[REGULAR]
    end

    def self.method_missing(*args)
      new.public_send(*args)
    end

    def self.respond_to_missing?(name, *)
      !!name[REGULAR] || instance_methods.include?(name)
    end
  end
end
